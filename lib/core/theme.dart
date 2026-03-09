import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE46A25); // Oranye khas makanan
  static const Color backgroundColor = Color(0xFFFAFAFA); // Putih tulang/cream
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF888888);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      fontFamily: 'Poppins', // Opsional kalau lu udah masukin font
    );
  }
}