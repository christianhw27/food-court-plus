import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Banner Pemberitahuan
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.amber.withValues(alpha: 0.2),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saat ini hanya mode pratinjau (katalog). Fitur pemesanan akan segera datang!',
                    style: TextStyle(color: Colors.brown, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Item Keranjang (Simulasi)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildCartItem(context, 'Ayam Geprek', 'Geprek Si Imut', 'Rp 15.000', 2),
                const SizedBox(height: 16),
                _buildCartItem(context, 'Es Teh Jumbo', 'Es Seger Boyolali', 'Rp 4.000', 1),
              ],
            ),
          ),

          // Ringkasan Pembayaran
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      const Text('Rp 34.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Biaya Layanan', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      const Text('Rp 2.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Rp 36.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Tombol Checkout (Disabled)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400, // Warna abu-abu menunjukan disabled
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Fitur Pembayaran Belum Tersedia')),
                         );
                      },
                      child: const Text('Lanjut Pembayaran (Segera)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, String name, String stall, String price, int qty) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(stall, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${qty}x', style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
