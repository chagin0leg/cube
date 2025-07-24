import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

extension FutureCropImageExtension on Future<ui.Image> {
  Future<ui.Image> crop() async {
    final image = await this;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return image;

    final Uint8List pixels = byteData.buffer.asUint8List();
    final int width = image.width, height = image.height;

    int top = height, bottom = 0, left = width, right = 0;
    bool hasOpaque = false;

    for (int y = 0; y < height; y++) {
      bool rowHasOpaque = false;
      final int rowStart = y * width * 4;

      for (int x = 0; x < width; x++) {
        final int index = rowStart + (x << 2) + 3;
        if (pixels[index] != 0) {
          rowHasOpaque = hasOpaque = true;
          if (x < left) left = x;
          if (x > right) right = x;
        }
      }

      if (rowHasOpaque) {
        if (y < top) top = y;
        bottom = y;
      }
    }

    if (!hasOpaque) return image;

    final int newWidth = right - left + 1;
    final int newHeight = bottom - top + 1;
    if (newWidth <= 0 || newHeight <= 0) return image;

    final Uint8List newPixels = Uint8List(newWidth * newHeight * 4);
    for (int y = 0; y < newHeight; y++) {
      final int srcStart = ((y + top) * width + left) * 4;
      final int dstStart = y * newWidth * 4;
      newPixels.setRange(dstStart, dstStart + newWidth * 4, pixels, srcStart);
    }

    return _decodeImage(newPixels, newWidth, newHeight);
  }

  Future<ui.Image> _decodeImage(Uint8List px, int w, int h) {
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(px, w, h, ui.PixelFormat.rgba8888, c.complete);
    return c.future;
  }
}
