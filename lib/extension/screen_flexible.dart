import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  double getWidth(double size) {
    const double designWidth = 440; // Ukuran desain (iPhone 16 Pro Max)
    return (size / designWidth) * screenWidth;
  }

  double getHeight(double size) {
    const double designHeight = 956; // Ukuran desain (iPhone 16 Pro Max)
    return (size / designHeight) * screenHeight;
  }
}
