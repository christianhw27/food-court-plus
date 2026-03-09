import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // <-- Tanda: Import Lottie
import '../core/theme.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "title": "Cari Menu Kampus Terenak",
      "subtitle": "Temukan puluhan stand makanan dan minuman di sekitar kampusmu.",
      "image": "assets/animations/onboarding_1.json" // <-- TANDA: Ganti nama file Lottie ke-1 lu di sini
    },
    {
      "title": "Pesan & Kalkulator Budget",
      "subtitle": "Hitung total belanjaanmu dan kontrol budget harianmu.",
      "image": "assets/animations/onboarding_2.json" // <-- TANDA: Ganti nama file Lottie ke-2 lu di sini
    },
    {
      "title": "Ambil Tanpa Antre",
      "subtitle": "Pesan dari aplikasi dan ambil di kasir saat sudah siap.",
      "image": "assets/animations/onboarding_3.json" // <-- TANDA: Ganti nama file Lottie ke-3 lu di sini
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- TANDA: Widget Lottie Lu Ada Di Sini ---
                    Lottie.asset(
                      onboardingData[index]["image"]!,
                      height: MediaQuery.of(context).size.height * 0.4,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      onboardingData[index]["title"]!,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        onboardingData[index]["subtitle"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: AppTheme.textLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Titik Indikator & Tombol
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indikator Titik
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => Container(
                        height: 10,
                        width: _currentPage == index ? 20 : 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppTheme.primaryColor : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  
                  // Tombol Aksi
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_currentPage == onboardingData.length - 1) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                      }
                    },
                    child: Text(_currentPage == onboardingData.length - 1 ? 'Finish' : 'Next', style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}