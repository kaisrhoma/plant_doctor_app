import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'asset_paths.dart';
import 'image_preprocessor.dart';
import 'tflite_runtime.dart';

class PlantResult {
  final String label;
  final double confidence; // 0..1
  const PlantResult({required this.label, required this.confidence});
}

class PlantClassifier {
  PlantClassifier._();
  static final PlantClassifier instance = PlantClassifier._();

  Interpreter? _interpreter;
  Map<String, String>? _labels; // index -> label

  Future<void> _ensureLoaded() async {
    if (_interpreter != null && _labels != null) return;

    final bd = await rootBundle.load(AssetPaths.plantModel);
    final bytes = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);

    // ✅ TFLite FlatBuffer identifier موجود في bytes[4..7]
    final header = (bytes.length >= 8) ? String.fromCharCodes(bytes.sublist(4, 8)) : '';
    if (bytes.length < 8 || header != 'TFL3') {
      throw Exception(
        'Plant model not valid TFLite: header=$header bytes=${bytes.length} path=${AssetPaths.plantModel}',
      );
    }

    _interpreter = await Interpreter.fromBuffer(
      bytes,
      options: TFLiteRuntime.options(),
    );

    final txt = await rootBundle.loadString(AssetPaths.plantLabels);
    final Map<String, dynamic> m = json.decode(txt);
    _labels = m.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  Future<PlantResult> classify(Uint8List imageBytes) async {
    await _ensureLoaded();
    final interpreter = _interpreter!;

    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape; // غالبًا [1,224,224,3]
    final size = inputShape[1];

    final input = ImagePreprocessor.toFloat32_0_1(imageBytes, size: size).reshape(inputShape);

    final outTensor = interpreter.getOutputTensor(0);
    final outShape = outTensor.shape; // [1,N] أو [N]
    final outLen = outShape.reduce((a, b) => a * b);

    final output = List.filled(outLen, 0.0).reshape(outShape);
    interpreter.run(input, output);

    final scores = _flattenToDoubles(output);
    final probs = _maybeSoftmax(scores);

    final bestIdx = _argMax(probs);
    final conf = probs[bestIdx];
    final label = _labels![bestIdx.toString()] ?? 'unknown';

    return PlantResult(label: label, confidence: conf);
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

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
