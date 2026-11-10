import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

abstract final class Breakpoints {
  static const double mobileMax = 767.0;
  static const double tabletMin = 768.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;

  static ScreenType getScreenType(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= desktopMin) return ScreenType.desktop;
    if (width >= tabletMin) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopMin;

  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return width >= tabletMin && width < desktopMin;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletMin;
}
