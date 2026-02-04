import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// يحوّل الصورة إلى Float32List (شكل [1, size, size, 3]) بقيم 0..1
class ImagePreprocessor {
  static Float32List toFloat32_0_1(Uint8List bytes, {int size = 224}) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Cannot decode image bytes');
    }

    final resized = img.copyResize(decoded, width: size, height: size);

    final out = Float32List(1 * size * size * 3);
    var i = 0;

    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final p = resized.getPixel(x, y); // Pixel

        // ✅ في image v4: استخدم p.r / p.g / p.b
        out[i++] = p.r / 255.0;
        out[i++] = p.g / 255.0;
        out[i++] = p.b / 255.0;
      }
    }
    return out;
  }
}
