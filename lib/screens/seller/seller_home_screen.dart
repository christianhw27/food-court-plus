import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/stall_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/stall_service.dart';
import 'seller_stall_profile_screen.dart';
import 'seller_manage_menu_screen.dart';
import 'seller_orders_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final _authService = AuthService();
  final _stallService = StallService();

  UserModel? _userData;
  StallModel? _stall;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.currentUserData;
    if (user == null) return;

    final stall = await _stallService.getStallByOwner(user.uid);
    if (mounted) {
      setState(() {
        _userData = user;
        _stall = stall;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStallStatus(bool value) async {
    if (_stall == null) return;
    await _stallService.toggleStallStatus(_stall!.id, value);
    setState(() => _stall = _stall!.copyWith(isOpen: value));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _stall == null
              ? _buildNoStallView()
              : _buildDashboardView(),
    );
  }

  // ============================================================
  // VIEW: belum punya stan
  // ============================================================
  Widget _buildNoStallView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.store_mall_directory_outlined,
                        color: AppTheme.primaryColor, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum Ada Stan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daftarkan stan kamu sekarang dan mulai jual makananmu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Daftarkan Stan Saya',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(
                              builder: (_) => SellerStallProfileScreen(stall: null, ownerUid: _userData!.uid),
                            ));
                        _loadData(); // Refresh setelah kembali
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VIEW: punya stan
  // ============================================================
  Widget _buildDashboardView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            // --- STALL HEADER CARD ---
            _buildStallCard(),
            const SizedBox(height: 24),

            // --- QUICK ACTIONS ---
            const Text('Menu Cepat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQuickAction(
                  icon: Icons.receipt_long,
                  label: 'Pesanan',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SellerOrdersScreen(stallId: _stall!.id)));
                  },
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Kelola Menu',
                  color: const Color(0xFF6366F1),
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SellerManageMenuScreen(stall: _stall!)));
                    _loadData();
                  },
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  icon: Icons.store_outlined,
                  label: 'Profil Stan',
                  color: const Color(0xFF10B981),
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => SellerStallProfileScreen(stall: _stall, ownerUid: _userData!.uid),
                        ));
                    _loadData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${_userData?.name ?? 'Penjual'}! 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            Text('Dashboard Penjual',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          child: const Icon(Icons.person, color: AppTheme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildStallCard() {
    final stall = _stall!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stall.name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(stall.category,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  ],
                ),
              ),
              // Toggle buka/tutup
              Column(
                children: [
                  Switch(
                    value: stall.isOpen,
                    onChanged: _toggleStallStatus,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green.shade300,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  ),
                  Text(
                    stall.isOpen ? 'Buka' : 'Tutup',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          if (stall.location.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(stall.location, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${stall.rating.toStringAsFixed(1)} (${stall.totalReviews} ulasan)',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 10),
              Text(label,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(Icons.logout, color: Colors.grey.shade600),
        label: Text('Keluar', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        onPressed: _confirmLogout,
      ),
    );
  }
}
