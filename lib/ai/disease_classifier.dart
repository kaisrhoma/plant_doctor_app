import 'dart:math';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// نتيجة التصنيف
class DiseaseResult {
  // هذه الحقول تبقى دائماً بالإنجليزية (الأكواد الأصلية من النموذج)
  final String rawPlant; // مثال: "Tomato"
  final String rawDisease; // مثال: "Late_blight"

  final double confidence;

  // هذه الحقول هي التي ستظهر في الواجهة (قابلة للتعريب)
  String title;
  String plant;

  final String description;
  final String? modelUsed;

  // ✅ الـ Getters الآن تعتمد على الحقول الخام التي لا تتغير أبداً
  String get plantCode => rawPlant.toLowerCase().trim();
  String get diseaseCode => rawDisease;

  DiseaseResult({
    required this.rawPlant,
    required this.rawDisease,
    required this.plant, // الاسم للعرض
    required this.title, // اسم المرض للعرض
    required this.confidence,
    required this.description,
    required this.modelUsed,
  });
}

/// Singleton Classifier
class DiseaseClassifier {
  DiseaseClassifier._();
  static final DiseaseClassifier instance = DiseaseClassifier._();

  late Interpreter _interpreter;
  late List<String> _labels;
  bool _loaded = false;

  /// تحميل النموذج والـ labels
  Future<void> load() async {
    if (_loaded) return;

    _interpreter = await Interpreter.fromAsset(
      'assets/model/plant_disease.tflite',
    );

    final rawLabels = await rootBundle.loadString('assets/labels.txt');
    _labels = rawLabels
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    _loaded = true;
  }

  /// التصنيف (مطابق 100% لـ PyTorch / Streamlit)
  Future<DiseaseResult> classify(Uint8List imageBytes) async {
    await load();

    // Decode image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Invalid image');
    }

    // Resize
    final resized = img.copyResize(image, width: 224, height: 224);

    // HWC -> NCHW
    final input = List.generate(
      1,
      (_) => List.generate(
        3,
        (c) => List.generate(
          224,
          (y) => List.generate(224, (x) {
            final pixel = resized.getPixel(x, y);
            final v = (c == 0)
                ? pixel.r
                : (c == 1)
                ? pixel.g
                : pixel.b;
            return v / 255.0;
          }),
        ),
      ),
    );

    // Output logits
    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

    _interpreter.run(input, output);

    final logits = output[0];

    // Softmax (نفس PyTorch)
    final maxLogit = logits.reduce(max);
    final exps = logits.map((e) => exp(e - maxLogit)).toList();
    final sumExp = exps.reduce((a, b) => a + b);
    final probs = exps.map((e) => e / sumExp).toList();

    final idx = probs.indexOf(probs.reduce(max));
    final confidence = probs[idx]; // 0..1

    // Decode label
    final fullLabel = _labels[idx]; // Plant___Disease
    final parts = fullLabel.split('___');

    final plant = parts[0].replaceAll(',', '');
    final disease = parts.length > 1 ? parts[1] : 'unknown';

    return DiseaseResult(
      rawPlant: plant, // يبقى إنجليزي للأبد
      rawDisease: disease, // يبقى إنجليزي للأبد
      plant: plant, // سيتغير للعربية لاحقاً في السكرين
      title: disease.replaceAll('_', ' '), // سيتغير للعربية لاحقاً في السكرين
      confidence: confidence,
      description: 'Model prediction',
      modelUsed: 'EfficientNet-B3 (TFLite)',
    );
  }
}