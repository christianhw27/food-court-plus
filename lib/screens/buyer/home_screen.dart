import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/food_model.dart';
import '../../models/stall_model.dart';
import '../../services/stall_service.dart';
import '../../services/saved_service.dart';
import 'food_detail_screen.dart';
import 'stall_detail_screen.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/app_network_image.dart';
import 'cart_screen.dart';
import '../../core/app_notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _userData;
  final _authService = AuthService();
  final _stallService = StallService();
  final _savedService = SavedService();

  late final Stream<Set<String>> _savedFoodIdsStream;
  late final Stream<Set<String>> _savedStallIdsStream;
  late final Stream<List<FoodModel>> _allFoodsStream;
  late final Stream<List<StallModel>> _allStallsStream;

  String _selectedCategory = 'Semua';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Semua', 'icon': Icons.restaurant_menu},
    {'label': 'Makanan Berat', 'icon': Icons.lunch_dining},
    {'label': 'Minuman', 'icon': Icons.local_cafe},
    {'label': 'Cemilan', 'icon': Icons.cookie},
    {'label': 'Kopi & Minuman Panas', 'icon': Icons.coffee},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _savedFoodIdsStream = _savedService.savedFoodIdsStream();
    _savedStallIdsStream = _savedService.savedStallIdsStream();
    _allFoodsStream = _stallService.getAllFoods().asBroadcastStream();
    _allStallsStream = _stallService.getAllStalls().asBroadcastStream();
  }

  void _loadUserData() async {
    final data = await _authService.currentUserData;
    if (mounted) setState(() => _userData = data);
  }

  // Filter makanan berdasarkan kategori yang dipilih
  List<FoodModel> _filterFoods(List<FoodModel> foods) {
    if (_selectedCategory == 'Semua') return foods;
    return foods.where((f) => f.category == _selectedCategory).toList();
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
      AppNotification.showSuccess(context, 'Gagal menyimpan menu. Coba lagi.');
    }
  }

  Future<void> _toggleSavedStall(String stallId) async {
    try {
      await _savedService.toggleStallSaved(stallId);
    } catch (_) {
      if (!mounted) return;
      AppNotification.showSuccess(context, 'Gagal menyimpan stan. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userData != null ? 'Halo, ${_userData!.name}! 👋' : 'Food Court Plus+',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Kantin Pusat UNESA',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context, MaterialPageRoute(builder: (_) => const CartScreen())),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFFFEEBC8),
                                child: Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFFFEEBC8),
                              child: Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- SEARCH BAR ---
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari makanan, minuman, stan...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white, size: 20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- KATEGORI ---
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories
                            .map((cat) => _buildCategoryChip(
                                  cat['label'] as String,
                                  cat['icon'] as IconData,
                                  _selectedCategory == cat['label'],
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
          body: StreamBuilder<Set<String>>(
            stream: _savedFoodIdsStream,
            builder: (context, savedFoodSnapshot) {
              return StreamBuilder<Set<String>>(
                stream: _savedStallIdsStream,
                builder: (context, savedStallSnapshot) {
                  return StreamBuilder<List<FoodModel>>(
                    stream: _allFoodsStream,
                    builder: (context, foodSnapshot) {
                      return StreamBuilder<List<StallModel>>(
                        stream: _allStallsStream,
                        builder: (context, stallSnapshot) {
                  final allFoods = foodSnapshot.data ?? [];
                  final allStalls = stallSnapshot.data ?? [];
                  final savedFoodIds = savedFoodSnapshot.data ?? <String>{};
                  final savedStallIds = savedStallSnapshot.data ?? <String>{};
                  final filteredFoods = _filterFoods(allFoods);
                  final isLoading =
                      (foodSnapshot.connectionState == ConnectionState.waiting && !foodSnapshot.hasData) ||
                      (stallSnapshot.connectionState == ConnectionState.waiting && !stallSnapshot.hasData) ||
                      (savedFoodSnapshot.connectionState == ConnectionState.waiting &&
                          !savedFoodSnapshot.hasData) ||
                      (savedStallSnapshot.connectionState == ConnectionState.waiting &&
                          !savedStallSnapshot.hasData);

                  if (isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- MENU POPULER ---
                        _buildSectionHeader('Menu Tersedia', '${filteredFoods.length} item'),
                        const SizedBox(height: 16),
                        if (filteredFoods.isEmpty)
                          _buildEmptyState(
                              icon: Icons.restaurant_menu_outlined,
                              message: _selectedCategory == 'Semua'
                                  ? 'Belum ada menu tersedia'
                                  : 'Tidak ada menu di kategori ini')
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: filteredFoods
                                  .map((food) => _buildFoodCard(
                                        food,
                                        allStalls,
                                        savedFoodIds.contains(food.id),
                                      ))
                                  .toList(),
                            ),
                          ),
                        const SizedBox(height: 32),

                        // --- STAN POPULER ---
                        _buildSectionHeader('Stan Tersedia', '${allStalls.length} stan'),
                        const SizedBox(height: 16),
                        if (allStalls.isEmpty)
                          _buildEmptyState(
                              icon: Icons.store_outlined,
                              message: 'Belum ada stan yang terdaftar')
                        else
                          ...allStalls
                              .map((stall) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildStallCard(
                                      stall,
                                      savedStallIds.contains(stall.id),
                                    ),
                                  )),
                      ],
                    ),
                  );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HELPER WIDGETS
  // ==========================================================

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        Text(subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.textDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(
    FoodModel food,
    List<StallModel> stalls,
    bool isSaved,
  ) {
    final stallName = stalls.firstWhere(
      (s) => s.id == food.stallId,
      orElse: () => StallModel(
          id: '', ownerUid: '', name: 'Stan', description: '', category: '', isOpen: false),
    ).name;

    final heroTag = 'food_${food.id}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodDetailScreen(food: food, stallName: stallName),
        ),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
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
            Stack(
              children: [
                Hero(
                  tag: heroTag,
                  child: AppNetworkImage(
                    imageUrl: food.imageUrl,
                    height: 120,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    placeholder: Container(
                      height: 120,
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleSavedFood(food.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_outline,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(stallName,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _formatPrice(food.price),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (food.rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            Text(food.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStallCard(StallModel stall, bool isSaved) {
    final heroTag = 'stall_${stall.id}';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StallDetailScreen(stall: stall)),
      ),
      child: Container(
        width: double.infinity,
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
            Hero(
              tag: heroTag,
              child: AppNetworkImage(
                imageUrl: stall.imageUrl,
                height: 130,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                placeholder: Container(
                  height: 130,
                  color: const Color(0xFFE2E8F0),
                  child: const Center(
                    child: Icon(Icons.storefront, color: Colors.grey, size: 50),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stall.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                        const SizedBox(height: 4),
                        Text(stall.category,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        if (stall.location.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13, color: Colors.grey.shade400),
                              const SizedBox(width: 2),
                              Text(stall.location,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _toggleSavedStall(stall.id),
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_outline,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (stall.rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(stall.rating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: stall.isOpen
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stall.isOpen ? 'Buka' : 'Tutup',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: stall.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade300, size: 52),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        ],
      ),
    );
  }
}