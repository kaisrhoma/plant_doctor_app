import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'asset_paths.dart';
import 'image_preprocessor.dart';
import 'plant_classifier.dart';

class DiseaseResult {
  final String plant;
  final String label;

  /// ✅ الآن: هذه الثقة = ثقة التعرف على النبات فقط
  final double confidence;

  final String title;
  final String description;
  final String? modelUsed;

  DiseaseResult({
    required this.plant,
    required this.label,
    required this.confidence,
    required this.title,
    required this.description,
    this.modelUsed,
  });
}

class DiseaseClassifier {
  DiseaseClassifier._();
  static final DiseaseClassifier instance = DiseaseClassifier._();

  final Map<String, Interpreter> _models = {};
  final Map<String, List<String>> _labels = {};

  static const int _inputSize = 224;

  Future<DiseaseResult> classify(Uint8List imageBytes) async {
    // =========================
    // 1) Plant Classification
    // =========================
    final plantRes = await PlantClassifier.instance.classify(imageBytes);
    final plant = _normalizePlant(plantRes.label);

    // ✅ ثقة النبات فقط
    final plantConfidence = plantRes.confidence;

    // إذا لم يتعرف على النبات
    if (plant == 'unknown') {
      return DiseaseResult(
        plant: 'unknown',
        label: 'unknown',
        confidence: 0, // ✅ نخليها 0 عشان ما تظهر في الواجهة
        title: 'تعذر التعرف على النبات',
        description:
            'لم نتمكن من تحديد نوع النبات بثقة كافية.\n'
            '📌 حاول تصوير الورقة بوضوح مع إضاءة جيدة وخلفية بسيطة.',
        modelUsed: null,
      );
    }

    // =========================
    // 2) Disease Model per Plant
    // =========================
    final modelPath = _plantToModel[plant];
    final labelsPath = _plantToLabels[plant];

    // النبات معروف لكن غير مدعوم داخل التطبيق
    if (modelPath == null || labelsPath == null) {
      return DiseaseResult(
        plant: plant,
        label: 'unsupported',
        confidence: plantConfidence, // ✅ ثقة النبات
        title: 'نبات مدعوم جزئياً',
        description:
            'تم التعرف على النبات بنجاح ✅\n'
            'لكن لا يوجد نموذج أمراض مخصص لهذا النبات داخل التطبيق حالياً.',
        modelUsed: null,
      );
    }

    // load model + labels
    final interpreter = await _loadModel(modelPath);
    final labels = await _loadLabels(labelsPath);

    // نوع المدخل
    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape;
    final isUint8 = inputTensor.type.toString().contains('uint8');

    debugPrint('Disease input type=${inputTensor.type} shape=$inputShape');

    // input
    final inputBuffer = ImagePreprocessor.toModelInput(
      imageBytes,
      size: _inputSize,
      inputTypeUint8: isUint8,
    );

    final input = (inputBuffer is Uint8List)
        ? inputBuffer.reshape(inputShape)
        : (inputBuffer as Float32List).reshape(inputShape);

    // output
    final output = ImagePreprocessor.createOutput(labels.length);
    interpreter.run(input, output);

    final probs = output[0];

    // Top3 debug
    final pairs = List.generate(probs.length, (i) => MapEntry(i, probs[i]));
    pairs.sort((a, b) => b.value.compareTo(a.value));
    final top3 = pairs
        .take(3)
        .map((e) => '${labels[e.key]}: ${(e.value * 100).toStringAsFixed(1)}%')
        .join(' | ');
    debugPrint('DISEASE TOP3 ($plant) => $top3');

    final bestIdx = pairs.first.key;
    final bestVal = pairs.first.value; // ✅ ثقة المرض (داخلية)
    final label = (bestIdx < labels.length) ? labels[bestIdx] : 'unknown';

    // Threshold للمرض (يمكنك تعديله لاحقاً)
    if (bestVal < 0.35) {
      return DiseaseResult(
        plant: plant,
        label: 'uncertain',
        confidence: plantConfidence, // ✅ ثقة النبات فقط
        title: 'النتيجة غير مؤكدة',
        description:
            'تم التعرف على النبات ✅ لكن تشخيص المرض غير واضح.\n'
            '📌 حاول التقاط صورة أقرب للورقة وتجنب الاهتزاز.\n'
            'ℹ️ (ثقة التشخيص: ${(bestVal * 100).toStringAsFixed(1)}%)',
        modelUsed: modelPath,
      );
    }

    final niceTitle = _prettyTitle(label);

    return DiseaseResult(
      plant: plant,
      label: label,
      confidence: plantConfidence, // ✅ ثقة النبات فقط
      title: niceTitle,
      description:
          '${_basicDescription(plant: plant, label: label)}\n'
          'ℹ️ (ثقة التشخيص: ${(bestVal * 100).toStringAsFixed(1)}%)',
      modelUsed: modelPath,
    );
  }

  Future<Interpreter> _loadModel(String modelAssetFullPath) async {
    if (_models.containsKey(modelAssetFullPath)) {
      return _models[modelAssetFullPath]!;
    }

    await rootBundle.load(modelAssetFullPath);

    final path1 = AssetPaths.toInterpreterAsset(modelAssetFullPath);
    final path2 = modelAssetFullPath;

    debugPrint('Disease model bundle = $modelAssetFullPath');
    debugPrint('Disease model fromAsset try1 = $path1');
    debugPrint('Disease model fromAsset try2 = $path2');

    try {
      final interpreter = await Interpreter.fromAsset(path1);
      _models[modelAssetFullPath] = interpreter;

      final inShape = interpreter.getInputTensor(0).shape;
      final outShape = interpreter.getOutputTensor(0).shape;
      debugPrint('Disease model shapes: in=$inShape out=$outShape');

      return interpreter;
    } catch (e1) {
      debugPrint('fromAsset try1 failed: $e1');
      try {
        final interpreter = await Interpreter.fromAsset(path2);
        _models[modelAssetFullPath] = interpreter;

        final inShape = interpreter.getInputTensor(0).shape;
        final outShape = interpreter.getOutputTensor(0).shape;
        debugPrint('Disease model shapes: in=$inShape out=$outShape');

        return interpreter;
      } catch (e2) {
        throw Exception(
          'Failed to load model.\n'
          'bundlePath=$modelAssetFullPath\n'
          'try1(fromAsset)=$path1 -> $e1\n'
          'try2(fromAsset)=$path2 -> $e2',
        );
      }
    }
  }

  Future<List<String>> _loadLabels(String labelsAssetFullPath) async {
    if (_labels.containsKey(labelsAssetFullPath)) {
      return _labels[labelsAssetFullPath]!;
    }

    final str = await rootBundle.loadString(labelsAssetFullPath);
    final decoded = jsonDecode(str);

    late final List<String> labels;
    if (decoded is Map) {
      final entries = decoded.entries.toList()
        ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
      labels = entries.map((e) => e.value.toString()).toList();
    } else if (decoded is List) {
      labels = decoded.map((e) => e.toString()).toList();
    } else {
      throw Exception('labels json format not supported');
    }

    _labels[labelsAssetFullPath] = labels;
    return labels;
  }

  void dispose() {
    for (final m in _models.values) {
      m.close();
    }
    _models.clear();
    _labels.clear();
  }

  String _normalizePlant(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('tomato')) return 'tomato';
    if (s.contains('potato')) return 'potato';
    if (s.contains('grape')) return 'grape';
    if (s.contains('pepper')) return 'pepper';
    return s;
  }

  static final Map<String, String> _plantToModel = {
    'tomato': AssetPaths.tomatoModel,
    'potato': AssetPaths.potatoModel,
    'grape': AssetPaths.grapeModel,
    'pepper': AssetPaths.pepperModel,
  };

  static final Map<String, String> _plantToLabels = {
    'tomato': AssetPaths.tomatoLabels,
    'potato': AssetPaths.potatoLabels,
    'grape': AssetPaths.grapeLabels,
    'pepper': AssetPaths.pepperLabels,
  };

  String _prettyTitle(String label) {
    final parts = label.replaceAll('-', '_').split('_');
    return parts
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  String _basicDescription({required String plant, required String label}) {
    if (label.toLowerCase().contains('healthy')) {
      return 'النبات يبدو سليماً ✅';
    }
    return 'تم اكتشاف: $label على $plant. افتح صفحة التفاصيل لطرق العلاج.';
  }
}
