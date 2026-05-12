import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/cart_item_model.dart';
import '../../services/cart_service.dart';
import '../../widgets/app_network_image.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    return 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Map<String, List<CartItemModel>> _getGroupedItems() {
    final Map<String, List<CartItemModel>> grouped = {};
    for (var item in _cartService.items) {
      final stallId = item.food.stallId;
      if (!grouped.containsKey(stallId)) {
        grouped[stallId] = [];
      }
      grouped[stallId]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: ListenableBuilder(
        listenable: _cartService,
        builder: (context, _) {
          if (_cartService.items.isEmpty) {
            return _buildEmptyCart();
          }

          final groupedItems = _getGroupedItems();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: groupedItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final stallId = groupedItems.keys.elementAt(index);
              final stallItems = groupedItems[stallId]!;
              final stallName = stallItems.first.stallName;

              return _buildStallSection(stallId, stallName, stallItems);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Keranjang masih kosong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Yuk, pilih menu favoritmu dulu!', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildStallSection(String stallId, String stallName, List<CartItemModel> stallItems) {
    final double subtotal = stallItems.fold(0, (sum, item) => sum + item.totalPrice);
    final double totalAmount = subtotal;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Stan
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.storefront, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  stallName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _cartService.clearCartByStall(stallId);
                  },
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // Daftar Item Keranjang untuk Stan ini
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: stallItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildCartItem(stallItems[index]);
            },
          ),

          const Divider(height: 1),

          // Ringkasan Pembayaran & Tombol Checkout
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    Text(_formatPrice(subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(_formatPrice(totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                  ],
                ),
                const SizedBox(height: 16),

                // Metode Pembayaran QRIS
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD0E4FF)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.qr_code_2, color: Color(0xFF1A73E8), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bayar pakai QRIS',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A3A5C)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'GoPay, OVO, Dana, ShopeePay',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Color(0xFF1A73E8), size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tombol Checkout
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            totalAmount: totalAmount,
                            stallId: stallId,
                            stallName: stallName,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Bayar dengan QRIS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    final food = item.food;
    return Row(
      children: [
        AppNetworkImage(
          imageUrl: food.imageUrl,
          width: 60,
          height: 60,
          borderRadius: BorderRadius.circular(10),
          placeholder: Container(
            color: const Color(0xFFE2E8F0),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(_formatPrice(food.price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => _cartService.updateQuantity(food.id, item.quantity - 1),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.remove, size: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () => _cartService.updateQuantity(food.id, item.quantity + 1),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, size: 14, color: AppTheme.primaryColor),
              ),
            ),
          ],
        )
      ],
    );
  }
}
