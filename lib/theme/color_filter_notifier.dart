import 'package:flutter/material.dart';

enum MyTheme {
  light('Light', [
    1, 0, 0, 0, 0, // R
    0, 1, 0, 0, 0, // G
    0, 0, 1, 0, 0, // B
    0, 0, 0, 1, 0, // A
  ]),
  dark('Dark', [
    -1, 0, 0, 0, 255, // R
    0, -1, 0, 0, 255, // G
    0, 0, -1, 0, 255, // B
    0, 0, 0, 1, 0, // A
  ]),
  marina('Marina', [
    0, 0, 0, 0, 0, // R
    0, 0, 0, 0, 0, // G
    0, 0, -1, 0, 255, // B
    0, 0, 0, 1, 0, // A
  ]),
  radioactive('Radioactive', [
    -0.7, 0, 0.3, 0, 0, // R
    0.2, 0, 0.2, 0, 0, // G
    -0.5, 0, 0.7, 0, 0, // B
    0, 0, 0, 1, 0, // A
  ]),
  bloody('Bloody', [
    1, 0, 0, 0, 0, // R
    0.2, 0, 0, 0, 0, // G
    0.2, 0, 0, 0, 0, // B
    0, 0, 0, 1, 0, // A
  ]),
  saint('Saint', [
    0.7, 0, 0.3, 0, 0, // R
    0.2, 0, 0.1, 0, 0, // G
    0.5, 0, 0.7, 0, 0, // B
    0, 0, 0, 1, 0, // A
  ]),
  sporty('Sporty', [
    0.7, 0, 0.3, 0, 0, // R
    0.2, 0, 0.1, 0, 0, // G
    -0.5, 0, 0.7, 0, 0, // B
    0, 0, 0, 1, 0, // A
  ]);

  final String _name;
  final List<double> _matrix;

  @override
  String toString() => _name;

  const MyTheme(this._name, this._matrix);
}

class ColorFilterNotifier extends ChangeNotifier {
  late MyTheme _currentTheme;
  late ColorFilter _filter;

  ColorFilterNotifier() {
    _currentTheme = MyTheme.light; // TODO: брать из настроек
    _filter = ColorFilter.matrix(_currentTheme._matrix);
  }

  ColorFilter get matrix => _filter;
  MyTheme get currentTheme => _currentTheme;

  void setTheme(MyTheme theme) {
    _currentTheme = theme;
    _setColorFilter(ColorFilter.matrix(_currentTheme._matrix));
  }

  void _setColorFilter(ColorFilter filter) {
    if (filter != _filter) {
      _filter = filter;
      notifyListeners();
    }
  }
}
