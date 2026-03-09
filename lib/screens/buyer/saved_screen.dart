import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

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
        body: TabBarView(
          children: [
            // --- TAB 1: MENU FAVORIT (GRID 2 KOLOM) ---
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Ngatur proporsi tinggi vs lebar kartu
              children: [
                _buildSavedFoodCard('Nasi Gila', 'Kantin Pak Gatot', 'Rp 15.000'),
                _buildSavedFoodCard('Es Coklat', 'Es Seger Muani-s', 'Rp 8.000'),
                _buildSavedFoodCard('Mie Nyemek', 'Spesialis Mie', 'Rp 12.000'),
                _buildSavedFoodCard('Ayam Geprek', 'Geprek Si Imut', 'Rp 15.000'),
              ],
            ),

            // --- TAB 2: STAN LANGGANAN (LIST VERTIKAL) ---
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSavedStallCard('Kantin Pak Gatot', 'Makanan Berat & Es', '4.8', true),
                const SizedBox(height: 16),
                _buildSavedStallCard('Es Seger Muani-s', 'Minuman', '4.6', true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK MENU FAVORIT ---
  Widget _buildSavedFoodCard(String name, String stall, String price) {
    return Container(
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
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                ),
                // Ikon Love Oranye di pojok kanan atas foto
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite, color: AppTheme.primaryColor, size: 16),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(stall, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK STAN LANGGANAN ---
  Widget _buildSavedStallCard(String name, String category, String rating, bool isOpen) {
    return Container(
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
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront, color: Colors.grey, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(category, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          const Icon(Icons.favorite, color: AppTheme.primaryColor),
        ],
      ),
    );
  }
}