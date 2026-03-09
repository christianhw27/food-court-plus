import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../main_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // --- 1. HEADER GEOMETRIS LENGKUNG (GRADIENT) ---
          ClipPath(
            clipper: HeaderCurveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45, // Mengisi 45% layar atas
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFBBF24), // Kuning Emas / Keju
                    AppTheme.primaryColor, // Oranye khas makanan
                  ],
                ),
              ),
            ),
          ),

          // --- 2. ORNAMEN TIPIS DI BACKGROUND (Opsional biar manis) ---
          Positioned(
            top: 50,
            right: -20,
            child: Icon(
              Icons.restaurant,
              size: 180,
              color: Colors.white.withValues(alpha: 0.15), // Putih transparan
            ),
          ),

          // --- 3. KONTEN UTAMA ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // --- TEKS HEADER (Di atas warna Oranye) ---
                  const Text(
                    'Food Court\nPlus+',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pesen menu favoritmu di kampus\ntanpa antre panjang.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- OVERLAPPING CARD (Kartu Form Login) ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10), // Bayangan jatuh ke bawah
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Mahasiswa',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          style: const TextStyle(color: AppTheme.textDark),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTheme.backgroundColor, // Sedikit krem biar beda sama putih card
                            hintText: 'nama@unesa.ac.id',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Password',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: true,
                          style: const TextStyle(color: AppTheme.textDark),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTheme.backgroundColor,
                            hintText: 'Minimal 8 karakter',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Lupa?', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- TOMBOL LOGIN ---
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              elevation: 4,
                              shadowColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MainLayout()),
                              );
                            },
                            child: const Text(
                              'Masuk Sekarang',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- LOGIN SOSMED & DAFTAR (Di luar kartu biar lega) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.g_mobiledata, Colors.red),
                      const SizedBox(width: 16),
                      _buildSocialButton(Icons.facebook, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun?', style: TextStyle(color: Colors.grey.shade600)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Daftar di sini', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget bantuan untuk tombol sosmed
  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}

// --- CLASS CUSTOM CLIPPER UNTUK BIKIN LENGKUNGAN HEADER ---
class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60); // Titik awal lengkungan di kiri
    
    // Titik kontrol (tengah) dan titik akhir (kanan)
    var controlPoint = Offset(size.width / 2, size.height + 20);
    var endPoint = Offset(size.width, size.height - 60);
    
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    
    path.lineTo(size.width, 0); // Garis ke kanan atas
    path.close(); // Tutup path kembali ke kiri atas
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}