import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        title: const Text('Pusat Bantuan',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent, color: AppTheme.primaryColor, size: 40),
                ),
                const SizedBox(height: 16),
                const Text('Ada yang bisa kami bantu?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Temukan jawaban dari pertanyaan yang sering diajukan',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // FAQ
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('PERTANYAAN UMUM',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500, letterSpacing: 0.5)),
                ),
                _faq('Bagaimana cara memesan makanan?',
                    'Pilih menu dari Home atau detail Stan, tap "Tambah ke Keranjang", lalu checkout dengan QRIS.'),
                _faq('Metode pembayaran apa yang tersedia?',
                    'QRIS yang bisa di-scan pakai GoPay, OVO, Dana, ShopeePay, dan m-banking.'),
                _faq('Bagaimana cara membatalkan pesanan?',
                    'Buka "Pesanan Saya" > tab "Belum Dibayar" > tap pesanan > "Batalkan Pesanan".'),
                _faq('Status pesanan belum berubah setelah bayar?',
                    'Tap "Cek Status Pembayaran" di detail pesanan. Jika masih bermasalah, hubungi admin.'),
                _faq('Bagaimana cara menyimpan menu favorit?',
                    'Tap ikon hati pada kartu menu. Menu tersimpan bisa dilihat di tab "Saved".'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Contact
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('HUBUNGI KAMI',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500, letterSpacing: 0.5)),
                ),
                _contact(Icons.email_outlined, 'Email', 'support@foodcourtplus.id'),
                const Divider(height: 1, indent: 60),
                _contact(Icons.phone_outlined, 'WhatsApp', '+62 812-xxxx-xxxx'),
                const Divider(height: 1, indent: 60),
                _contact(Icons.access_time, 'Jam Operasional', 'Senin - Sabtu, 07:00 - 17:00 WIB'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _faq(String q, String a) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.help_outline, color: AppTheme.primaryColor, size: 18),
      ),
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      children: [Text(a, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6))],
    );
  }

  Widget _contact(IconData icon, String title, String sub) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.textDark, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    );
  }
}
