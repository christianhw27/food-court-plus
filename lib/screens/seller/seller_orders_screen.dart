import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../core/app_notification.dart';

class SellerOrdersScreen extends StatefulWidget {
  final String stallId;

  const SellerOrdersScreen({super.key, required this.stallId});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final OrderService _orderService = OrderService();

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    return 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      if (!mounted) return;
      AppNotification.showSuccess(context, 'Status pesanan diperbarui menjadi $newStatus');
    } catch (e) {
      if (!mounted) return;
      AppNotification.showSuccess(context, 'Gagal memperbarui status pesanan');
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
          iconTheme: const IconThemeData(color: AppTheme.textDark),
          title: const Text(
            'Kelola Pesanan',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Pesanan Aktif'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: _orderService.getStallOrders(widget.stallId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }

            final orders = snapshot.data ?? [];
            final activeOrders = orders.where((o) => o.status == 'Sedang Disiapkan' || o.status == 'Menunggu Pembayaran').toList();
            final completedOrders = orders.where((o) => o.status == 'Selesai' || o.status == 'Dibatalkan').toList();

            return TabBarView(
              children: [
                _buildOrderList(activeOrders, isActive: true),
                _buildOrderList(completedOrders, isActive: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Belum ada pesanan aktif' : 'Belum ada riwayat',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        final itemsStr = order.items.map((i) => '${i['quantity']}x ${i['name']}').join('\n');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(order.status)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(itemsStr, style: const TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Pembayaran:', style: TextStyle(color: Colors.grey.shade600)),
                  Text(_formatPrice(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (order.status == 'Menunggu Pembayaran') ...[
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => _updateStatus(order.id, 'Dibatalkan'),
                          child: const Text('Batalkan'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                          onPressed: () => _updateStatus(order.id, 'Sedang Disiapkan'),
                          child: const Text('Terima', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                    if (order.status == 'Sedang Disiapkan') ...[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () => _updateStatus(order.id, 'Selesai'),
                          child: const Text('Selesaikan Pesanan', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Pembayaran': return Colors.orange;
      case 'Sedang Disiapkan': return Colors.blue;
      case 'Selesai': return Colors.green;
      case 'Dibatalkan': return Colors.red;
      default: return Colors.grey;
    }
  }
}
