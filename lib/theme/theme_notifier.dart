import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light; // TODO: доставать из сохранённых настроек?

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }
}
