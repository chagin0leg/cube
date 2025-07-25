import 'package:flutter/material.dart';

class ColorFilterNotifier extends ChangeNotifier {
  ColorFilter _matrix = ColorFilter.matrix([
    1, 0, 0, 0, 0, // R
    0, 1, 0, 0, 0, // G
    0, 0, 1, 0, 0, // B
    0, 0, 0, 1, 0, // A
  ]);
  String _currentTheme = 'Light'; // TODO: брать из настроек

  ColorFilter get matrix => _matrix;
  String get currentTheme => _currentTheme;

  void setTheme(String theme) {
    List<double> redChannel = [1, 0, 0, 0, 0];
    List<double> greenChannel = [0, 1, 0, 0, 0];
    List<double> blueChannel = [0, 0, 1, 0, 0];
    List<double> alphaChannel = [0, 0, 0, 1, 0];

    switch (theme) {
      case 'Dark':
        _currentTheme = 'Dark';
        redChannel = [-1, 0, 0, 0, 255];
        greenChannel = [0, -1, 0, 0, 255];
        blueChannel = [0, 0, -1, 0, 255];
        break;
      case 'Marina':
        _currentTheme = 'Marina';
        redChannel = [0, 0, 0, 0, 0];
        greenChannel = [0, 0, 0, 0, 0];
        blueChannel = [0, 0, -1, 0, 255];
        break;
      case 'Radioactive':
        _currentTheme = 'Radioactive';
        redChannel = [-0.7, 0, 0.3, 0, 0];
        greenChannel = [0.2, 0, 0.2, 0, 0];
        blueChannel = [-0.5, 0, 0.7, 0, 0];
        break;
      case 'Bloody':
        _currentTheme = 'Bloody';
        greenChannel = [0.2, 0, 0, 0, 0];
        blueChannel = [0.2, 0, 0, 0, 0];
        break;
      case 'Saint':
        _currentTheme = 'Saint';
        redChannel = [0.7, 0, 0.3, 0, 0];
        greenChannel = [0.2, 0, 0.1, 0, 0];
        blueChannel = [0.5, 0, 0.7, 0, 0];
        break;
      case 'Sporty':
        _currentTheme = 'Sporty';
        redChannel = [0.7, 0, 0.3, 0, 0];
        greenChannel = [0.2, 0, 0.1, 0, 0];
        blueChannel = [-0.5, 0, 0.7, 0, 0];
        break;
      case 'Light':
      default:
        _currentTheme = 'Light';
        break;
    }

    _setMatrix(
      alphaChannel: alphaChannel,
      blueChannel: blueChannel,
      greenChannel: greenChannel,
      redChannel: redChannel,
    );
  }

  void _setMatrix({
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
