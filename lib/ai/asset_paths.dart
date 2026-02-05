class AssetPaths {
  AssetPaths._();

  /// ✅ هذا المسار للـ rootBundle (لازم يبدأ بـ assets/)
  static const String bundleBase = 'assets/model/data_models_plus_lapels';

  /// ✅ هذا المسار لـ Interpreter.fromAsset (بدون assets/)
  static const String interpreterBase = 'model/data_models_plus_lapels';

  // Models (TFLite) — full path for rootBundle
  static const String plantModel = '$bundleBase/plant_classifier.tflite';
  static const String tomatoModel = '$bundleBase/tomato_disease_model.tflite';
  static const String potatoModel = '$bundleBase/potato_disease_model.tflite';
  static const String pepperModel = '$bundleBase/pepper_disease_model.tflite';
  static const String grapeModel  = '$bundleBase/grape_disease_model.tflite';

  // Labels (JSON)
  static const String plantLabels  = '$bundleBase/plant_classifier_labels.json';
  static const String tomatoLabels = '$bundleBase/tomato_disease_labels.json';
  static const String potatoLabels = '$bundleBase/potato_disease_labels.json';
  static const String pepperLabels = '$bundleBase/pepper_disease_labels.json';
  static const String grapeLabels  = '$bundleBase/grape_disease_labels.json';

  /// ✅ يحوّل من مسار bundle (assets/..) إلى مسار interpreter (بدون assets/)
  static String toInterpreterAsset(String bundlePath) {
    // مثال: assets/model/... -> model/...
    if (bundlePath.startsWith('assets/')) {
      return bundlePath.substring('assets/'.length);
    }
    return bundlePath; // احتياط
  }
}
