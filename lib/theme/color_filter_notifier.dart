import 'package:flutter/material.dart';

class ColorFilterNotifier extends ChangeNotifier {
  ColorFilter _matrix = ColorFilter.matrix([
    1, 0, 0, 0, 0, // R
    0, 1, 0, 0, 0, // G
    0, 0, 1, 0, 0, // B
    0, 0, 0, 1, 0, // A
  ]);

  ColorFilter get matrix => _matrix;

  void setMatrix({
    List<double>? redChannel,
    List<double>? greenChannel,
    List<double>? blueChannel,
    List<double>? alphaChannel,
  }) {
    assert(
      (redChannel == null || redChannel.length == 5) &&
          (greenChannel == null || greenChannel.length == 5) &&
          (blueChannel == null || blueChannel.length == 5) &&
          (alphaChannel == null || alphaChannel.length == 5),
      "ColorFilter channel length is not equal to 5",
    );

    ColorFilter newMatrix = _matrix;
    newMatrix = ColorFilter.matrix([
      ...redChannel ?? [1, 0, 0, 0, 0], // R
      ...greenChannel ?? [0, 1, 0, 0, 0], // G
      ...blueChannel ?? [0, 0, 1, 0, 0], // B
      ...alphaChannel ?? [0, 0, 0, 1, 0], // A
    ]);

    if (newMatrix != _matrix) {
      _matrix = newMatrix;
      notifyListeners();
    }
  }
}
