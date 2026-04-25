import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/food_model.dart';
import '../../services/saved_service.dart';
import '../../widgets/app_network_image.dart';
import '../../core/app_notification.dart';
import '../../services/cart_service.dart';

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
      AppNotification.showSuccess(context, 'Gagal menyimpan menu. Coba lagi.');
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

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: food.isAvailable ? AppTheme.primaryColor : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: food.isAvailable
                          ? () {
                              try {
                                CartService().addToCart(food, stallName);
                                AppNotification.showSuccess(context, '${food.name} ditambahkan ke keranjang');
                              } catch (e) {
                                AppNotification.showError(context, e.toString().replaceAll('Exception: ', ''));
                              }
                            }
                          : null,
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: Text(
                        food.isAvailable ? 'Tambah ke Keranjang' : 'Habis Terjual',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
