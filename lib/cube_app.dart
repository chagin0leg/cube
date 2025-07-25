import 'package:cube/parallelepipeds_app.dart';
import 'package:cube/theme/app_theme.dart';
import 'package:cube/theme/color_filter_notifier.dart';
import 'package:cube/theme/color_filter_provider.dart';
import 'package:flutter/material.dart';

class CubeApp extends StatelessWidget {
  CubeApp({super.key});

  final ColorFilterNotifier _colorFilterNotifier = ColorFilterNotifier();

  @override
  Widget build(BuildContext context) {
    return ColorFilterProvider(
      notifier: _colorFilterNotifier,
      child: AnimatedBuilder(
        animation: _colorFilterNotifier,
        builder: (context, _) {
          return ColorFiltered(
            colorFilter: _colorFilterNotifier.matrix,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              home: ParallelepipedsApp(),
            ),
          );
        },
      ),
    );
  }
}
