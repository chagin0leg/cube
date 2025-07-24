import 'package:cube/theme/theme_notifier.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends InheritedNotifier<ThemeNotifier> {
  const ThemeProvider({
    super.key,
    required ThemeNotifier super.notifier,
    required super.child,
  });

  static ThemeNotifier of(BuildContext context) {
    ThemeProvider? provider =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, "No ThemeProvider in element tree found");

    return provider!.notifier!;
  }
}
