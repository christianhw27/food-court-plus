import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/food_model.dart';
import '../../models/stall_model.dart';
import '../../services/saved_service.dart';
import '../../services/stall_service.dart';
import '../../widgets/app_network_image.dart';
import 'food_detail_screen.dart';
import '../../core/app_notification.dart';

class StallDetailScreen extends StatelessWidget {
  final StallModel stall;

  const StallDetailScreen({super.key, required this.stall});

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    return 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _toggleSavedStall(BuildContext context, SavedService savedService) async {
    try {
      await savedService.toggleStallSaved(stall.id);
    } catch (_) {
      if (!context.mounted) return;
      AppNotification.showSuccess(context, 'Gagal menyimpan stan. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = 'stall_${stall.id}';
    final stallService = StallService();
    final savedService = SavedService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // 1. SliverAppBar dengan banner
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              StreamBuilder<Set<String>>(
                stream: savedService.savedStallIdsStream(),
                builder: (context, snapshot) {
                  final isSaved = (snapshot.data ?? <String>{}).contains(stall.id);
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () => _toggleSavedStall(context, savedService),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                stall.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
              background: Hero(
                tag: heroTag,
                child: AppNetworkImage(
                  imageUrl: stall.imageUrl,
                  width: double.infinity,
                  placeholder: Container(
                    color: const Color(0xFFE2E8F0),
                    child: const Center(
                      child: Icon(Icons.storefront, color: Colors.grey, size: 80),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Info Stan
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Kiri: Kategori & Rating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stall.category,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                stall.rating > 0
                                    ? '${stall.rating.toStringAsFixed(1)} (${stall.totalReviews} ulasan)'
                                    : 'Belum ada ulasan',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          if (stall.location.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 15, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(stall.location,
                                    style: TextStyle(
                                        color: Colors.grey.shade500, fontSize: 13)),
                              ],
                            ),
                          ],
                        ],
                      ),
                      // Kanan: Status buka/tutup
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: stall.isOpen
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stall.isOpen ? '🟢  Buka' : '🔴  Tutup',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: stall.isOpen ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (stall.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(stall.description,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 4),
                  const Text('Menu Tersedia',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // 3. Grid Menu dari Firestore
          StreamBuilder<List<FoodModel>>(
            stream: stallService.getFoodByStall(stall.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                  ),
                );
              }

              final foods = snapshot.data ?? [];

              if (foods.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_menu_outlined,
                            color: Colors.grey.shade300, size: 52),
                        const SizedBox(height: 12),
                        Text('Belum ada menu di stan ini',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildMenuGridItem(context, foods[index]),
                    childCount: foods.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGridItem(BuildContext context, FoodModel food) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodDetailScreen(food: food, stallName: stall.name),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4)),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    placeholder: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                    ),
                  ),
                  // Badge tidak tersedia
                  if (!food.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Center(
                          child: Text('Habis',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(food.price),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 13),
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
