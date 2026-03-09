import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita pakai DefaultTabController buat bikin tab atas yang bisa di-swipe
    return DefaultTabController(
      length: 2, // Ada 2 Tab
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Berlangsung'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: BERLANGSUNG ---
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildOrderCard(
                  stallName: 'Nasi Campur Khas Ngawi',
                  orderId: '#FCP-09812',
                  date: 'Hari ini, 12:30 WIB',
                  items: '2x Ayam Geprek, 1x Es Teh Jumbo',
                  price: 'Rp 34.000',
                  status: 'Sedang Disiapkan',
                  statusColor: Colors.blue,
                  icon: Icons.soup_kitchen,
                  actionButton: 'Lihat QR Antrean',
                  isActionPrimary: true,
                ),
                const SizedBox(height: 16),
                _buildOrderCard(
                  stallName: 'Warung Kopi Mr. Ironi',
                  orderId: '#FCP-09813',
                  date: 'Hari ini, 12:45 WIB',
                  items: '1x Kopi Susu Gula Aren',
                  price: 'Rp 12.000',
                  status: 'Menunggu Pembayaran',
                  statusColor: Colors.orange,
                  icon: Icons.pending_actions,
                  actionButton: 'Bayar Sekarang',
                  isActionPrimary: true,
                ),
                const SizedBox(height: 80), // Padding bawah buat bottom nav
              ],
            ),

            // --- TAB 2: RIWAYAT ---
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildOrderCard(
                  stallName: 'Geprek Si Imut',
                  orderId: '#FCP-08701',
                  date: 'Kemarin, 13:00 WIB',
                  items: '1x Nasi Campur Spesial',
                  price: 'Rp 18.000',
                  status: 'Selesai',
                  statusColor: Colors.green,
                  icon: Icons.check_circle,
                  actionButton: 'Pesan Lagi',
                  isActionPrimary: false,
                ),
                const SizedBox(height: 16),
                _buildOrderCard(
                  stallName: 'Mas Amba Nasi Goreng',
                  orderId: '#FCP-08655',
                  date: '02 Feb 2026, 11:15 WIB',
                  items: '1x Nasi Goreng, 1x Es Jeruk',
                  price: 'Rp 17.000',
                  status: 'Dibatalkan',
                  statusColor: Colors.red,
                  icon: Icons.cancel,
                  actionButton: 'Cari Menu Lain',
                  isActionPrimary: false,
                ),
                const SizedBox(height: 80), // Padding bawah buat bottom nav
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK KARTU PESANAN ---
  Widget _buildOrderCard({
    required String stallName,
    required String orderId,
    required String date,
    required String items,
    required String price,
    required String status,
    required Color statusColor,
    required IconData icon,
    required String actionButton,
    required bool isActionPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu: Nama Stan & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(stallName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          
          // Isi Pesanan
          Text(items, style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$orderId • $date', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 16),

          // Tombol Aksi
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isActionPrimary ? AppTheme.primaryColor : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: isActionPrimary ? Colors.transparent : AppTheme.primaryColor),
                ),
              ),
              onPressed: () {},
              child: Text(
                actionButton,
                style: TextStyle(
                  color: isActionPrimary ? Colors.white : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}