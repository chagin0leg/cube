import 'package:cube/theme/color_filter_notifier.dart';
import 'package:flutter/material.dart';

class ColorFilterProvider extends InheritedNotifier<ColorFilterNotifier> {
  const ColorFilterProvider({
    super.key,
    required ColorFilterNotifier super.notifier,
    required super.child,
  });

  static ColorFilterNotifier of(BuildContext context) {
    ColorFilterProvider? provider =
        context.dependOnInheritedWidgetOfExactType<ColorFilterProvider>();
    assert(provider != null, "No ColorFilterNotifier in element tree found");

    return provider!.notifier!;
  }
}
