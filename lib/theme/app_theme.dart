import 'package:cube/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    scaffoldBackgroundColor: AppColors.platinum,
  );

  static final ThemeData dark = ThemeData(
    scaffoldBackgroundColor: AppColors.darkGrey,
  );
}
