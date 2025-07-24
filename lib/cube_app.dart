import 'package:cube/parallelepipeds_app.dart';
import 'package:cube/theme/app_theme.dart';
import 'package:cube/theme/theme_notifier.dart';
import 'package:cube/theme/theme_provider.dart';
import 'package:flutter/material.dart';

class CubeApp extends StatelessWidget {
  CubeApp({super.key});

  final ThemeNotifier _themeNotifier = ThemeNotifier();

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      notifier: _themeNotifier,
      child: AnimatedBuilder(
        animation: _themeNotifier,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _themeNotifier.mode,
            home: ParallelepipedsApp(),
          );
        },
      ),
    );
  }
}
