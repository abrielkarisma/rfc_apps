import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  double getWidth(double size) {
    const double designWidth = 440; 
    return (size / designWidth) * screenWidth;
  }

  double getHeight(double size) {
    const double designHeight = 956; 
    return (size / designHeight) * screenHeight;
  }
}
