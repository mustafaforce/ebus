import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand & accent
  static const Color primary = Color(0xFF0066CC);
  static const Color primaryFocus = Color(0xFF0071E3);
  static const Color primaryOnDark = Color(0xFF2997FF);

  // Surface
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color parchment = Color(0xFFF5F5F7);
  static const Color surfacePearl = Color(0xFFFAFAFC);
  static const Color tile1 = Color(0xFF272729);
  static const Color tile2 = Color(0xFF2A2A2C);
  static const Color tile3 = Color(0xFF252527);
  static const Color black = Color(0xFF000000);
  static const Color chipTranslucent = Color(0xFFD2D2D7);

  // Text
  static const Color ink = Color(0xFF1D1D1F);
  static const Color body = Color(0xFF1D1D1F);
  static const Color bodyOnDark = Color(0xFFFFFFFF);
  static const Color bodyMuted = Color(0xFFCCCCCC);
  static const Color inkMuted80 = Color(0xFF333333);
  static const Color inkMuted48 = Color(0xFF7A7A7A);

  // Hairlines
  static const Color dividerSoft = Color(0xFFF0F0F0);
  static const Color hairline = Color(0xFFE0E0E0);
}

class AppRadius {
  AppRadius._();
  static const double xs = 5;
  static const double sm = 8;
  static const double md = 11;
  static const double lg = 18;
  static const double pill = 9999;
}

class AppSpacing {
  AppSpacing._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 17;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double section = 80;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> product = [
    BoxShadow(
      color: Color(0x38000000),
      blurRadius: 30,
      offset: Offset(3, 5),
    ),
  ];
}
