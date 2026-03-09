// main.dart
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/onboarding_screen.dart'; // Import onboarding

void main() {
  runApp(const FoodCourtApp());
}

class FoodCourtApp extends StatelessWidget {
  const FoodCourtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Court Plus+',
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(), // <-- Arahkan ke OnboardingScreen
    );
  }
}