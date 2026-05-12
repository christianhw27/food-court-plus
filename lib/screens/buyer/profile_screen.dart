import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'help_center_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userData;
  final _authService = AuthService();
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final data = await _authService.currentUserData;
    if (mounted) {
      setState(() {
        _userData = data;
      });
    }
  }

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    return 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Yakin mau keluar dari akun ini?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _authService.signOut();
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profil Saya', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER IDENTITAS ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFFEEBC8),
                    child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData?.name ?? 'Loading...',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData?.email ?? 'Memuat data...',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Member Premium', style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- KARTU STATISTIK BUDGET (REAL DATA) ---
            _buildStatsSection(),
            const SizedBox(height: 8),

            // --- MENU PENGATURAN ---
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuTile(Icons.person_outline, 'Edit Profil', true, () {
                    if (_userData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditProfileScreen(userData: _userData!)),
                      ).then((result) {
                        if (result == true) _loadUserData();
                      });
                    }
                  }),
                  _buildMenuTile(Icons.track_changes, 'Target Budget Harian', true, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur ini segera hadir!'), backgroundColor: Colors.orange),
                    );
                  }),
                  _buildMenuTile(Icons.notifications_none, 'Notifikasi', true, () {
                    _navigateTo(const NotificationSettingsScreen());
                  }),
                  _buildMenuTile(Icons.help_outline, 'Pusat Bantuan', true, () {
                    _navigateTo(const HelpCenterScreen());
                  }),
                  _buildMenuTile(Icons.info_outline, 'Tentang Aplikasi', false, () {
                    _navigateTo(const AboutScreen());
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- TOMBOL KELUAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await _confirmLogout();
                  },
                  child: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- STATS SECTION WITH REAL DATA ---
  Widget _buildStatsSection() {
    if (_userData == null) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.getBuyerOrders(_userData!.uid),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];

        // Calculate monthly spending from completed/paid orders
        final now = DateTime.now();
        final monthlyOrders = orders.where((o) =>
            o.createdAt.month == now.month &&
            o.createdAt.year == now.year &&
            (o.status == 'Selesai' || o.status == 'Sedang Disiapkan'),
        ).toList();
        final monthlySpending = monthlyOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);

        // Total completed orders (all time)
        final totalOrders = orders.where((o) => o.status != 'Dibatalkan').length;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Color(0xFFFBBF24)),
                      const SizedBox(height: 12),
                      const Text('Pengeluaran Bulan Ini', style: TextStyle(fontSize: 12, color: AppTheme.textDark)),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(monthlySpending),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fastfood, color: AppTheme.primaryColor),
                      const SizedBox(height: 12),
                      const Text('Total Pesanan', style: TextStyle(fontSize: 12, color: AppTheme.textDark)),
                      const SizedBox(height: 4),
                      Text(
                        '$totalOrders Pesanan',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET BANTUAN UNTUK LIST MENU ---
  Widget _buildMenuTile(IconData icon, String title, bool showDivider, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppTheme.textDark, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 60, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}