import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'asset_paths.dart';
import 'image_preprocessor.dart';

class PlantPrediction {
  final String label;
  final double confidence;

  PlantPrediction({required this.label, required this.confidence});
}

class PlantClassifier {
  PlantClassifier._();
  static final PlantClassifier instance = PlantClassifier._();

  Interpreter? _interpreter;
  List<String>? _labels;

  static const int _inputSize = 224;

  // ✅ إعدادات رفض "ليس نبات" (تقدر تعدلها بسهولة)
  static const double _minConf = 0.55;     // أقل ثقة لقبول نبات
  static const double _minMargin = 0.12;   // فرق top1-top2
  static const double _minGreen = 0.06;    // نسبة الأخضر في الصورة

  Future<void> _ensureLoaded() async {
    if (_interpreter != null && _labels != null) return;

    // ✅ تأكد وجود الملف في assets (لو pubspec غلط سيفشل هنا)
    await rootBundle.load(AssetPaths.plantModel);

    final path1 = AssetPaths.toInterpreterAsset(AssetPaths.plantModel);
    final path2 = AssetPaths.plantModel;

    debugPrint('Plant model bundle = ${AssetPaths.plantModel}');
    debugPrint('Plant model fromAsset try1 = $path1');
    debugPrint('Plant model fromAsset try2 = $path2');

    try {
      _interpreter = await Interpreter.fromAsset(path1);
    } catch (e) {
      debugPrint('fromAsset try1 failed: $e');
      _interpreter = await Interpreter.fromAsset(path2);
    }

    // Labels
    final labelsStr = await rootBundle.loadString(AssetPaths.plantLabels);
    final decoded = jsonDecode(labelsStr);

    if (decoded is Map) {
      final entries = decoded.entries.toList()
        ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
      _labels = entries.map((e) => e.value.toString()).toList();
    } else if (decoded is List) {
      _labels = decoded.map((e) => e.toString()).toList();
    } else {
      throw Exception('plant labels json format not supported');
    }

    if (_labels!.isEmpty) throw Exception('plant labels empty');

    final inShape = _interpreter!.getInputTensor(0).shape;
    final outShape = _interpreter!.getOutputTensor(0).shape;
    debugPrint('Plant model shapes: in=$inShape out=$outShape');
  }

  Future<PlantPrediction> classify(Uint8List imageBytes) async {
    await _ensureLoaded();

    final labels = _labels!;
    final interpreter = _interpreter!;

    // ✅ اعرف نوع مدخل الموديل
    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape; // غالباً [1,224,224,3]
    final isUint8 = inputTensor.type.toString().contains('uint8');

    // ✅ جهّز input حسب النوع
    final inputBuffer = ImagePreprocessor.toModelInput(
      imageBytes,
      size: _inputSize,
      inputTypeUint8: isUint8,
    );

    // ✅ output
    final output = ImagePreprocessor.createOutput(labels.length);

    final input = (inputBuffer is Uint8List)
        ? inputBuffer.reshape(inputShape)
        : (inputBuffer as Float32List).reshape(inputShape);

    interpreter.run(input, output);

    final probs = output[0];

    // أفضل index
    int bestIdx = 0;
    double bestVal = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > bestVal) {
        bestVal = probs[i];
        bestIdx = i;
      }
    }

    // ثاني أفضل قيمة لحساب margin
    double secondVal = 0.0;
    for (int i = 0; i < probs.length; i++) {
      if (i == bestIdx) continue;
      if (probs[i] > secondVal) secondVal = probs[i];
    }
    final margin = bestVal - secondVal;

    final bestLabel = (bestIdx < labels.length) ? labels[bestIdx] : 'unknown';

    // ✅ فحص الأخضر (قوي لمعرفة هل الصورة نبات أصلاً)
    final green = ImagePreprocessor.greenRatio(imageBytes);

    // ✅ Debug يساعدك تضبط القيم
    debugPrint('PLANT best=$bestLabel conf=${(bestVal * 100).toStringAsFixed(1)}% '
        'margin=${margin.toStringAsFixed(3)} green=${green.toStringAsFixed(3)}');

    // ✅ بوابة رفض "ليس نبات"
    if (bestVal < _minConf || margin < _minMargin || green < _minGreen) {
      return PlantPrediction(label: 'unknown', confidence: bestVal);
    }

    return PlantPrediction(label: bestLabel, confidence: bestVal);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
