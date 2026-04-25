import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();
  String? _buyerUid;

  @override
  void initState() {
    super.initState();
    _authService.currentUserData.then((user) {
      if (mounted && user != null) {
        setState(() => _buyerUid = user.uid);
      }
    });
  }

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    return 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Menunggu Pembayaran': return Icons.pending_actions;
      case 'Sedang Disiapkan': return Icons.soup_kitchen;
      case 'Selesai': return Icons.check_circle;
      case 'Dibatalkan': return Icons.cancel;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_buyerUid == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    return DefaultTabController(
      length: 2,
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
        body: StreamBuilder<List<OrderModel>>(
          stream: _orderService.getBuyerOrders(_buyerUid!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }

            final orders = snapshot.data ?? [];
            final ongoingOrders = orders.where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan').toList();
            final historyOrders = orders.where((o) => o.status == 'Selesai' || o.status == 'Dibatalkan').toList();

            return TabBarView(
              children: [
                _buildOrderList(ongoingOrders, isEmptyOngoing: true),
                _buildOrderList(historyOrders, isEmptyOngoing: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, {required bool isEmptyOngoing}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isEmptyOngoing ? 'Belum ada pesanan berlangsung' : 'Belum ada riwayat pesanan',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        final itemsStr = order.items.map((i) => '${i['quantity']}x ${i['name']}').join(', ');

        return _buildOrderCard(
          stallName: order.stallName,
          orderId: order.id.substring(0, 8).toUpperCase(),
          date: '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
          items: itemsStr,
          price: _formatPrice(order.totalAmount),
          status: order.status,
          statusColor: _getStatusColor(order.status),
          icon: _getStatusIcon(order.status),
          actionButton: order.status == 'Selesai' ? 'Pesan Lagi' : 'Lihat Detail',
          isActionPrimary: order.status != 'Selesai' && order.status != 'Dibatalkan',
        );
      },
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.storefront, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stallName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
          Text(items, style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#$orderId • $date', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
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