import 'package:flutter/material.dart';

class ScreenUtil {
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600; // 600dp tablet eşiği olarak kabul edilir
  }

  static double getAdaptiveTextSize(BuildContext context, double value) {
    // Tablet için text boyutlarını ayarla
    return isTablet(context) ? value * 1.5 : value;
  }

  static double getAdaptiveIconSize(BuildContext context, double value) {
    // Tablet için icon boyutlarını ayarla
    return isTablet(context) ? value * 1.3 : value;
  }

  static EdgeInsets getAdaptivePadding(BuildContext context, {
    double horizontal = 16.0,
    double vertical = 16.0,
  }) {
    // Tablet için padding değerlerini ayarla
    final multiplier = isTablet(context) ? 1.5 : 1.0;
    return EdgeInsets.symmetric(
      horizontal: horizontal * multiplier,
      vertical: vertical * multiplier,
    );
  }

  static double getAdaptiveCardWidth(BuildContext context, double baseWidth) {
    // Tablet için kart genişliklerini ayarla
    return isTablet(context) ? baseWidth * 1.5 : baseWidth;
  }

  static double getAdaptiveCardHeight(BuildContext context, double baseHeight) {
    // Tablet için kart yüksekliklerini ayarla
    return isTablet(context) ? baseHeight * 1.3 : baseHeight;
  }

  static double getAdaptiveGridSpacing(BuildContext context, double baseSpacing) {
    // Tablet için grid boşluklarını ayarla
    return isTablet(context) ? baseSpacing * 1.5 : baseSpacing;
  }

  static int getAdaptiveGridCrossAxisCount(BuildContext context, int baseCount) {
    // Tablet için grid sütun sayısını ayarla
    return isTablet(context) ? (baseCount + 1) : baseCount;
  }
} 