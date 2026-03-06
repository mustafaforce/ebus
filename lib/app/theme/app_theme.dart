import 'package:flutter/material.dart';
import 'package:ebus/app/theme/dark_app_theme.dart';
import 'package:ebus/app/theme/light_app_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => LightAppTheme.theme;

  static ThemeData get darkTheme => DarkAppTheme.theme;

  static ThemeMode get themeMode => ThemeMode.system;
}
