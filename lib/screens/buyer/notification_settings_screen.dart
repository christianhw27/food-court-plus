import 'package:flutter/material.dart';
import '../../core/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _stallUpdates = true;
  bool _paymentAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        title: const Text(
          'Pengaturan Notifikasi',
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Notification settings
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'Notifikasi Pesanan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildSwitchTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Update Status Pesanan',
                    subtitle: 'Dapatkan notifikasi saat pesanan diproses dan selesai',
                    value: _orderUpdates,
                    onChanged: (v) => setState(() => _orderUpdates = v),
                  ),
                  const Divider(height: 1, indent: 60, color: Color(0xFFEEEEEE)),
                  _buildSwitchTile(
                    icon: Icons.payment_outlined,
                    title: 'Notifikasi Pembayaran',
                    subtitle: 'Konfirmasi pembayaran dan pengingat',
                    value: _paymentAlerts,
                    onChanged: (v) => setState(() => _paymentAlerts = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'Notifikasi Lainnya',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildSwitchTile(
                    icon: Icons.storefront_outlined,
                    title: 'Update Stan Favorit',
                    subtitle: 'Notifikasi ketika stan favoritmu buka atau menambah menu baru',
                    value: _stallUpdates,
                    onChanged: (v) => setState(() => _stallUpdates = v),
                  ),
                  const Divider(height: 1, indent: 60, color: Color(0xFFEEEEEE)),
                  _buildSwitchTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Promosi & Penawaran',
                    subtitle: 'Dapatkan info diskon dan promo spesial',
                    value: _promotions,
                    onChanged: (v) => setState(() => _promotions = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pengaturan notifikasi ini hanya berlaku untuk notifikasi dalam aplikasi. '
                      'Untuk mengatur notifikasi push, buka pengaturan perangkatmu.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value ? AppTheme.primaryColor : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppTheme.primaryColor,
        onChanged: onChanged,
      ),
    );
  }
}
