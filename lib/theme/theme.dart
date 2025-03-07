import 'package:flutter/material.dart';

///
/// Definition of App colors.
///
class DertamColors {
  static Color primary = const Color(0xFF00aff5);
  static Color backgroundAccent = const Color(0xFFEDEDED);
  static Color neutralDark = const Color(0xFF054752);
  static Color neutral = const Color(0xFF3d5c62);
  static Color neutralLight = const Color(0xFF708c91);
  static Color neutralLighter = const Color(0xFF92A7AB);
  static Color greyLight = const Color(0xFFE2E2E2);
  static Color white = Colors.white;
  static Color get backGroundColor {
    return DertamColors.primary;
  }

  static Color get textNormal {
    return DertamColors.neutralDark;
  }

  static Color get textLight {
    return DertamColors.neutralLight;
  }
  static Color get iconNormal {
    return DertamColors.neutral;
  }
  static Color get iconLight {
    return DertamColors.neutralLighter;
  }
  static Color get disabled {
    return DertamColors.greyLight;
  }
}
///
/// Definition of App text styles.
///
class DertamTextStyles {
  static TextStyle heading =
      const TextStyle(fontSize: 28, fontWeight: FontWeight.w500);
  static TextStyle title =
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w400);
  static TextStyle body =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle label =
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
  static TextStyle button =
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
}

///
/// Definition of App spacings, in pixels.
/// Bascially small (S), medium (m), large (l), extra large (x), extra extra large (xxl)
///
class DertamSpacings {
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 40;

  static const double radius = 16;
  static const double radiusLarge = 24;
}

class DertamSize {
  static const double icon = 24;
}

///
/// Definition of App Theme.
///
ThemeData appTheme = ThemeData(
  fontFamily: 'Eesti',
  scaffoldBackgroundColor: Colors.white,
);