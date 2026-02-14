import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteRuntime {
  TFLiteRuntime._();

  static InterpreterOptions options() {
    final opt = InterpreterOptions();

    // Threads (جرّب 2 أو 4 حسب الجهاز)
    opt.threads = 2;

    //  CPU delegate الأكثر شيوعًا (يساعد في الأداء وأحيانًا يحل مشاكل الإنشاء)
    try {
      opt.addDelegate(XNNPackDelegate());
    } catch (_) {}

    // على أندرويد: اترك NNAPI مغلق كبداية لتجنب مشاكل بعض الأجهزة
    if (Platform.isAndroid) {
      try {
        opt.useNnApiForAndroid = false;
      } catch (_) {}
    }

    return opt;
  }
}
