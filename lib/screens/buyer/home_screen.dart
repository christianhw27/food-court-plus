import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Food Court Plus+',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      Text(
                        'Kantin Pusat UNESA',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFFEEBC8), // Oranye pudar
                    child: Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
              const SizedBox(height: 24),

              // --- KATEGORI HORIZONTAL ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Semua', Icons.restaurant_menu, true),
                    _buildCategoryChip('Makanan Berat', Icons.lunch_dining, false),
                    _buildCategoryChip('Minuman', Icons.local_cafe, false),
                    _buildCategoryChip('Cemilan', Icons.cookie, false),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- POPULAR FOOD SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Menu Populer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Semua', style: TextStyle(color: AppTheme.primaryColor)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFoodCard('Ayam Geprek', 'Kantin Mas Rusdi', 'Rp 15.000', '4.8'),
                    _buildFoodCard('Nasi Campur', 'Warung Pak Gatot', 'Rp 12.000', '4.6'),
                    _buildFoodCard('Es Teh Jumbo', 'Es Seger Boyolali', 'Rp 4.000', '4.9'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- BAGIAN STAN POPULER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Stan Populer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Semua', style: TextStyle(color: AppTheme.primaryColor)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              // List Vertikal untuk Stan
              _buildStallCard('Kantin Mas Rusdi', 'Makanan Berat & Es', '4.8', true),
              const SizedBox(height: 16),
              _buildStallCard('Warung Pak Gatot', 'Kopi & Cemilan', '4.6', true),
              const SizedBox(height: 16),
              _buildStallCard('Geprek Si Imut', 'Makanan Spesial', '4.9', false),
              
              const SizedBox(height: 40), // Padding bawah biar gak mentok navigasi
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGET BANTUAN (HELPER METHODS)
  // ==========================================================

  // 1. Widget Bantuan untuk Kategori
  Widget _buildCategoryChip(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : AppTheme.textDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textDark,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Widget Bantuan untuk Kartu Makanan
  Widget _buildFoodCard(String name, String stall, String price, String rating) {
    return Container(
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
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(stall, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // 3. Widget Bantuan untuk Kartu Stan
  Widget _buildStallCard(String name, String category, String rating, bool isOpen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Icon(Icons.storefront, color: Colors.grey, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOpen ? 'Buka' : 'Tutup',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isOpen ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}