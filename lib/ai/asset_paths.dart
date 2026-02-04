class AssetPaths {
  AssetPaths._();

  // ✅ في مشروعك: fromAsset يحتاج المسار مع assets/
  static const String base = 'assets/model/data_models_plus_lapels';

  // Models (TFLite)
  static const String plantModel  = '$base/plant_classifier.tflite';
  static const String tomatoModel = '$base/tomato_disease_model.tflite';
  static const String potatoModel = '$base/potato_disease_model.tflite';
  static const String pepperModel = '$base/pepper_disease_model.tflite';
  static const String grapeModel  = '$base/grape_disease_model.tflite';

  // Labels (JSON)
  static const String plantLabels  = '$base/plant_classifier_labels.json';
  static const String tomatoLabels = '$base/tomato_disease_labels.json';
  static const String potatoLabels = '$base/potato_disease_labels.json';
  static const String pepperLabels = '$base/pepper_disease_labels.json';
  static const String grapeLabels  = '$base/grape_disease_labels.json';
}
