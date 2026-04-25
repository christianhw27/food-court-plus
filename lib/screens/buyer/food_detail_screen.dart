import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/food_model.dart';
import '../../services/saved_service.dart';
import '../../widgets/app_network_image.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodModel food;
  final String stallName;

  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.stallName,
  });

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    return 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _toggleSavedFood(BuildContext context, SavedService savedService) async {
    try {
      await savedService.toggleFoodSaved(food.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan menu. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = 'food_${food.id}';
    final savedService = SavedService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Gambar Makanan (Setengah layar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Hero(
              tag: heroTag,
              child: AppNetworkImage(
                imageUrl: food.imageUrl,
                width: double.infinity,
                placeholder: Container(
                  color: const Color(0xFFE2E8F0),
                  child: const Center(
                    child: Icon(Icons.fastfood, color: Colors.grey, size: 80),
                  ),
                ),
              ),
            ),
          ),

          // 2. Tombol Back melayang di atas gambar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back, color: AppTheme.textDark),
              ),
            ),
          ),

          // 3. Tombol Favorit melayang di atas gambar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: StreamBuilder<Set<String>>(
              stream: savedService.savedFoodIdsStream(),
              builder: (context, snapshot) {
                final isSaved = (snapshot.data ?? <String>{}).contains(food.id);
                return GestureDetector(
                  onTap: () => _toggleSavedFood(context, savedService),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                    ),
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_outline,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Panel Detail Makanan (Bawah)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4 - 20,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatPrice(food.price),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Nama Stan & Rating
                  Row(
                    children: [
                      const Icon(Icons.storefront, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(stallName,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      if (food.rating > 0) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(food.rating.toStringAsFixed(1),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Badge kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      food.category,
                      style:
                          const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),

                  // Deskripsi
                  const Text('Deskripsi',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 8),
                  Text(
                    food.description.isNotEmpty
                        ? food.description
                        : 'Tidak ada deskripsi untuk menu ini.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                  ),

                  const Spacer(),

                  // Info: fitur order belum tersedia
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Fitur pemesanan akan segera hadir. Saat ini kamu hanya bisa melihat katalog.',
                            style: TextStyle(
                                color: Colors.orange.shade700, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
