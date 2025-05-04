import 'package:flutter/material.dart';

class ThemeHelper {
  static Color getMaterialForTheme(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'purple':
        return const Color(0xFFEDE7F6);
      case 'blue':
        return const Color(0xFFE3F2FD);
      case 'green':
        return const Color(0xFFE8F5E9);
      case 'pink':
        return const Color(0xFFFCE4EC);
      case 'metal':
        return const Color(0xFFE0E0E0);
      case 'wood':
        return const Color(0xFFEFEBE9);
      case 'glass':
        return const Color(0xFFE1F5FE);
      default:
        return const Color(0xFFFFFFFF);
    }
  }
}
