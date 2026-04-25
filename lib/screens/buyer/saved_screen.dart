import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/food_model.dart';
import '../../models/stall_model.dart';
import '../../services/saved_service.dart';
import '../../services/stall_service.dart';
import '../../widgets/app_network_image.dart';
import 'food_detail_screen.dart';
import 'stall_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _savedService = SavedService();
  final _stallService = StallService();

  // Data disimpan di state, bukan di StreamBuilder
  Set<String> _savedFoodIds = {};
  Set<String> _savedStallIds = {};
  List<FoodModel> _allFoods = [];
  List<StallModel> _allStalls = [];
  bool _isLoading = true;

  // Manual subscriptions — tetap hidup walau pindah tab
  StreamSubscription<Set<String>>? _foodIdsSub;
  StreamSubscription<Set<String>>? _stallIdsSub;
  StreamSubscription<List<FoodModel>>? _foodsSub;
  StreamSubscription<List<StallModel>>? _stallsSub;

  @override
  void initState() {
    super.initState();

    _foodIdsSub = _savedService.savedFoodIdsStream().listen((ids) {
      if (mounted) setState(() { _savedFoodIds = ids; _isLoading = false; });
    });

    _stallIdsSub = _savedService.savedStallIdsStream().listen((ids) {
      if (mounted) setState(() { _savedStallIds = ids; _isLoading = false; });
    });

    _foodsSub = _stallService.getAllFoodsUnfiltered().listen((foods) {
      if (mounted) setState(() { _allFoods = foods; _isLoading = false; });
    });

    _stallsSub = _stallService.getAllStalls().listen((stalls) {
      if (mounted) setState(() { _allStalls = stalls; _isLoading = false; });
    });
  }

  @override
  void dispose() {
    _foodIdsSub?.cancel();
    _stallIdsSub?.cancel();
    _foodsSub?.cancel();
    _stallsSub?.cancel();
    super.dispose();
  }

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    return 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _toggleSavedFood(String foodId) async {
    try {
      await _savedService.toggleFoodSaved(foodId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus menu tersimpan.')),
      );
    }
  }

  Future<void> _toggleSavedStall(String stallId) async {
    try {
      await _savedService.toggleStallSaved(stallId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus stan tersimpan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Tersimpan',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Menu Favorit'),
              Tab(text: 'Stan Langganan'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : TabBarView(
                children: [
                  _buildSavedFoodsTab(),
                  _buildSavedStallsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildSavedFoodsTab() {
    final foodsById = {for (final food in _allFoods) food.id: food};
    final stallsById = {for (final stall in _allStalls) stall.id: stall};
    final savedFoods = _savedFoodIds
        .where((id) => foodsById.containsKey(id))
        .map((id) => foodsById[id]!)
        .toList();

    if (savedFoods.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_outline,
        title: 'Belum ada menu favorit',
        subtitle: 'Tap ikon hati di menu yang kamu suka supaya muncul di sini.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: savedFoods.length,
      itemBuilder: (context, index) {
        final food = savedFoods[index];
        final stallName = stallsById[food.stallId]?.name ?? 'Stan';
        return _buildSavedFoodCard(food, stallName);
      },
    );
  }

  Widget _buildSavedStallsTab() {
    final stallsById = {for (final stall in _allStalls) stall.id: stall};
    final savedStalls = _savedStallIds
        .where((id) => stallsById.containsKey(id))
        .map((id) => stallsById[id]!)
        .toList();

    if (savedStalls.isEmpty) {
      return _buildEmptyState(
        icon: Icons.store_outlined,
        title: 'Belum ada stan favorit',
        subtitle: 'Simpan stan langgananmu agar mudah ditemukan lagi.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => _buildSavedStallCard(savedStalls[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: savedStalls.length,
    );
  }

  Widget _buildSavedFoodCard(FoodModel food, String stallName) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food, stallName: stallName)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  AppNetworkImage(
                    imageUrl: food.imageUrl,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    placeholder: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleSavedFood(food.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, color: AppTheme.primaryColor, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stallName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(food.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      fontSize: 14,
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

  Widget _buildSavedStallCard(StallModel stall) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StallDetailScreen(stall: stall)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: stall.imageUrl,
              height: 70,
              width: 70,
              borderRadius: BorderRadius.circular(12),
              placeholder: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront, color: Colors.grey, size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stall.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(stall.category, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        stall.rating > 0 ? stall.rating.toStringAsFixed(1) : '-',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: stall.isOpen
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stall.isOpen ? 'Buka' : 'Tutup',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: stall.isOpen ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _toggleSavedStall(stall.id),
              child: const Icon(Icons.favorite, color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}