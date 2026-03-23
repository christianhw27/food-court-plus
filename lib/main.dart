import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart'; // Import onboarding

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home:
          const OnboardingScreen(), // <-- Arahkan ke OnboardingScreenjdbjasbdjasbdj
    );
  }
}
