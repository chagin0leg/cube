import 'package:cube/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    scaffoldBackgroundColor: AppColors.platinum,
    splashFactory: NoSplash.splashFactory,
    textTheme: TextTheme(
      titleSmall: TextStyle(
        fontSize: 16,
        color: AppColors.darkPlatinum,
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 2,
      activeTrackColor: AppColors.grey,
      inactiveTrackColor: AppColors.lightGrey,
      thumbColor: AppColors.grey,
      overlayColor: AppColors.transparent,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      tickMarkShape: SliderTickMarkShape.noTickMark,
      valueIndicatorShape: SliderComponentShape.noOverlay,
      showValueIndicator: ShowValueIndicator.never,
      trackShape: const RoundedRectSliderTrackShape(),
    ),
    iconTheme: IconThemeData(color: AppColors.grey, size: 48),
  );
}
