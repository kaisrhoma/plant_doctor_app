import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'asset_paths.dart';
import 'image_preprocessor.dart';
import 'plant_classifier.dart';
import 'tflite_runtime.dart';

class DiseaseResult {
  final String plant;
  final String label;
  final double confidence;
  final String title;
  final String description;
  final String? modelUsed;

  const DiseaseResult({
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

  static const _modelByPlant = <String, String>{
    'tomato': AssetPaths.tomatoModel,
    'potato': AssetPaths.potatoModel,
    'pepper': AssetPaths.pepperModel,
    'grape': AssetPaths.grapeModel,
  };

  static const _labelsByPlant = <String, String>{
    'tomato': AssetPaths.tomatoLabels,
    'potato': AssetPaths.potatoLabels,
    'pepper': AssetPaths.pepperLabels,
    'grape': AssetPaths.grapeLabels,
  };

  Future<DiseaseResult> classify(Uint8List imageBytes) async {
    final plantRes = await PlantClassifier.instance.classify(imageBytes);
    final plant = _normalizePlant(plantRes.label);

    final modelPath = _modelByPlant[plant];
    final labelsPath = _labelsByPlant[plant];

    if (modelPath == null || labelsPath == null) {
      return const DiseaseResult(
        plant: 'unknown',
        label: 'unknown',
        confidence: 0,
        title: 'غير مدعوم',
        description: 'هذا النبات غير مدعوم حالياً في مودلات الأمراض.',
        modelUsed: null,
      );
    }

    final interpreter = await _loadModel(modelPath);
    final labels = await _loadLabels(labelsPath);

    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape;
    final size = inputShape[1];

    final input = ImagePreprocessor.toFloat32_0_1(imageBytes, size: size).reshape(inputShape);

    final outTensor = interpreter.getOutputTensor(0);
    final outShape = outTensor.shape;
    final outLen = outShape.reduce((a, b) => a * b);

    final output = List.filled(outLen, 0.0).reshape(outShape);
    interpreter.run(input, output);

    final scores = _flattenToDoubles(output);
    final probs = _maybeSoftmax(scores);

    final bestIdx = _argMax(probs);
    final conf = probs[bestIdx];
    final label = (bestIdx < labels.length) ? labels[bestIdx] : 'unknown';

    return DiseaseResult(
      plant: plant,
      label: label,
      confidence: conf,
      title: _prettyTitle(label),
      description: _basicDescription(plant: plant, label: label),
      modelUsed: modelPath,
    );
  }

  Future<Interpreter> _loadModel(String modelPath) async {
    if (_models.containsKey(modelPath)) return _models[modelPath]!;

    final bd = await rootBundle.load(modelPath);
    final bytes = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);

    // ✅ TFLite FlatBuffer identifier موجود في bytes[4..7]
    final header = (bytes.length >= 8) ? String.fromCharCodes(bytes.sublist(4, 8)) : '';
    if (bytes.length < 8 || header != 'TFL3') {
      throw Exception(
        'Disease model not valid TFLite: header=$header bytes=${bytes.length} path=$modelPath',
      );
    }

    final i = await Interpreter.fromBuffer(
      bytes,
      options: TFLiteRuntime.options(),
    );
    _models[modelPath] = i;
    return i;
  }

  Future<List<String>> _loadLabels(String labelsPath) async {
    if (_labels.containsKey(labelsPath)) return _labels[labelsPath]!;

    final txt = await rootBundle.loadString(labelsPath);
    final decoded = json.decode(txt);

    late final List<String> labels;

    if (decoded is Map) {
      final entries = decoded.entries.toList()
        ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
      labels = entries.map((e) => e.value.toString()).toList();
    } else if (decoded is List) {
      labels = decoded.map((e) => e.toString()).toList();
    } else {
      throw Exception('labels json format not supported: $labelsPath');
    }

    _labels[labelsPath] = labels;
    return labels;
  }

  List<double> _flattenToDoubles(dynamic output) {
    final flat = <double>[];
    void walk(dynamic v) {
      if (v is List) {
        for (final e in v) walk(e);
      } else if (v is num) {
        flat.add(v.toDouble());
      }
    }
    walk(output);
    return flat;
  }

  List<double> _maybeSoftmax(List<double> v) {
    final sum = v.fold<double>(0, (a, b) => a + b);
    final allInRange = v.every((x) => x >= 0 && x <= 1);
    if (allInRange && (sum - 1.0).abs() < 0.05) return v;

    final maxV = v.reduce(math.max);
    final exps = v.map((x) => math.exp(x - maxV)).toList();
    final s = exps.fold<double>(0, (a, b) => a + b);
    if (s == 0) return v;
    return exps.map((e) => e / s).toList();
  }

  int _argMax(List<double> v) {
    var bestI = 0;
    var bestV = v[0];
    for (var i = 1; i < v.length; i++) {
      if (v[i] > bestV) {
        bestV = v[i];
        bestI = i;
      }
    }
    return bestI;
  }

  String _normalizePlant(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('tomato')) return 'tomato';
    if (s.contains('potato')) return 'potato';
    if (s.contains('pepper')) return 'pepper';
    if (s.contains('grape')) return 'grape';
    return 'unknown';
  }

  String _prettyTitle(String label) {
    final parts = label.replaceAll('-', '_').split('_');
    return parts.map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
  }

  String _basicDescription({required String plant, required String label}) {
    if (label.toLowerCase().contains('healthy')) return 'النبات يبدو سليماً ✅';
    return 'تم اكتشاف: $label على $plant. افتح صفحة التفاصيل لطرق العلاج.';
  }

  void dispose() {
    for (final m in _models.values) {
      m.close();
    }
    _models.clear();
    _labels.clear();
  }
}
