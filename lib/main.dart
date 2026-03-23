import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart'; // Import onboarding
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Cek apakah baru pertama kali buka app
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(FoodCourtApp(showOnboarding: isFirstTime));
}

class FoodCourtApp extends StatelessWidget {
  final bool showOnboarding;
  const FoodCourtApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Court Plus+',
      theme: AppTheme.lightTheme,
      home: showOnboarding ? const OnboardingScreen() : const AuthWrapper(),
    );
  }
}
