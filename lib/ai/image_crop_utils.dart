import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;

class ImageCropUtils {
  static Uint8List cropToRect({
    required Uint8List bytes,
    required Size imageSize,
    required Rect cropRect,
  }) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Cannot decode image');
    }

    final x = cropRect.left.round().clamp(0, image.width - 1);
    final y = cropRect.top.round().clamp(0, image.height - 1);
    final w = cropRect.width.round().clamp(1, image.width - x);
    final h = cropRect.height.round().clamp(1, image.height - y);

    final cropped = img.copyCrop(
      image,
      x: x,
      y: y,
      width: w,
      height: h,
    );

    return Uint8List.fromList(img.encodeJpg(cropped, quality: 95));
  }
}
