import 'package:anitrack/utils/appearance_theme.dart';
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>() ??
        AppThemeFactory.paletteFor(AppStyle.anilist, Brightness.dark);
  }
}

