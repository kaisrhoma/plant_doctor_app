import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImagePreprocessor {
  ImagePreprocessor._();

  /// ✅ يرجّع قيمة 0..1 تقريبًا: كلما زادت يعني الصورة فيها أخضر (أوراق/نبات)
  static double greenRatio(Uint8List bytes, {int sampleSize = 128}) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return 0.0;

    final small =
        img.copyResize(decoded, width: sampleSize, height: sampleSize);

    int greenish = 0;
    final total = sampleSize * sampleSize;

    for (int y = 0; y < sampleSize; y++) {
      for (int x = 0; x < sampleSize; x++) {
        final p = small.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();

        // شرط "أخضر": g أكبر من r و b بفارق بسيط + شوية قوة لون
        if (g > r + 15 && g > b + 15 && g > 60) {
          greenish++;
        }
      }
    }
    return greenish / total;
  }

  /// ✅ ترجع input جاهز لـ tflite:
  /// - لو inputTypeUint8=true -> Uint8List (0..255)
  /// - لو false -> Float32List (0..1)
  static Object toModelInput(
    Uint8List bytes, {
    int size = 224,
    required bool inputTypeUint8,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Cannot decode image bytes');
    }

    final resized = img.copyResize(decoded, width: size, height: size);

    if (inputTypeUint8) {
      final out = Uint8List(1 * size * size * 3);
      int i = 0;
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          final px = resized.getPixel(x, y);
          out[i++] = px.r.toInt();
          out[i++] = px.g.toInt();
          out[i++] = px.b.toInt();
        }
      }
      return out;
    } else {
      final out = Float32List(1 * size * size * 3);
      int i = 0;
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          final px = resized.getPixel(x, y);
          out[i++] = px.r / 255.0;
          out[i++] = px.g / 255.0;
          out[i++] = px.b / 255.0;
        }
      }
      return out;
    }
  }

  static List<List<double>> createOutput(int numClasses) {
    return List.generate(1, (_) => List.filled(numClasses, 0.0));
  }
}
