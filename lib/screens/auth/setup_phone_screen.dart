import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/app_notification.dart';
import '../../widgets/auth_wrapper.dart';

class SetupPhoneScreen extends StatefulWidget {
  const SetupPhoneScreen({super.key});

  @override
  State<SetupPhoneScreen> createState() => _SetupPhoneScreenState();
}

class _SetupPhoneScreenState extends State<SetupPhoneScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _savePhone() async {
    if (_phoneController.text.trim().isEmpty) {
      AppNotification.showError(context, 'Tolong masukkan nomor HP (WhatsApp)');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'phone': _phoneController.text.trim(),
        });
        
        if (mounted) {
          AppNotification.showSuccess(context, 'Nomor HP berhasil disimpan');
          // AuthWrapper will automatically rebuild and let user pass since phone is no longer empty
          // But to be safe, we pushReplacement to AuthWrapper
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(context, 'Gagal menyimpan nomor HP: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Lengkapi Profil', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.phone_android, size: 64, color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Satu langkah lagi!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mohon masukkan nomor HP (WhatsApp) kamu agar penjual mudah menghubungimu jika ada kendala dengan pesanan.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              const Text('Nomor HP (WhatsApp)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '08123456789',
                  prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _savePhone,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan & Lanjutkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
