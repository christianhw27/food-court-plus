import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'payment_screen.dart';
import '../../services/louvin_service.dart';

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

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Menunggu Pembayaran': return 'Silakan lakukan pembayaran';
      case 'Sedang Disiapkan': return 'Pesanan sedang dibuat oleh penjual';
      case 'Selesai': return 'Pesanan selesai';
      case 'Dibatalkan': return 'Pesanan dibatalkan';
      default: return '';
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
      length: 3,
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
              Tab(text: 'Belum Dibayar'),
              Tab(text: 'Diproses'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: _orderService.getBuyerOrders(_buyerUid!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal memuat pesanan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        'Pesan Error Asli:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        onPressed: () => setState(() {}),
                      ),
                    ],
                  ),
                ),
              );
            }

            final orders = snapshot.data ?? [];
            final unpaidOrders = orders.where((o) => o.status == 'Menunggu Pembayaran').toList();
            final processingOrders = orders.where((o) => o.status == 'Sedang Disiapkan').toList();
            final completedOrders = orders.where((o) => o.status == 'Selesai' || o.status == 'Dibatalkan').toList();

            return TabBarView(
              children: [
                _buildOrderList(unpaidOrders, emptyTitle: 'Belum ada pesanan', emptySubtitle: 'Pesanan yang belum dibayar akan muncul di sini'),
                _buildOrderList(processingOrders, emptyTitle: 'Belum ada pesanan diproses', emptySubtitle: 'Pesanan yang sedang disiapkan penjual akan muncul di sini'),
                _buildOrderList(completedOrders, emptyTitle: 'Belum ada riwayat pesanan', emptySubtitle: 'Riwayat pesanan kamu akan muncul di sini'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, {required String emptyTitle, required String emptySubtitle}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  void _showOrderDetail(OrderModel order) {
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Detail Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(order.status), size: 14, color: _getStatusColor(order.status)),
                      const SizedBox(width: 4),
                      Text(order.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(order.status))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _getStatusDescription(order.status),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const Divider(height: 32),

            // Stan info
            Row(
              children: [
                const Icon(Icons.storefront, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(order.stallName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '#${order.id.substring(0, 8).toUpperCase()} • ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),

            // Items
            const Text('Pesanan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...order.items.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${i['quantity']}x ${i['name']}', style: const TextStyle(fontSize: 14)),
                  Text(_formatPrice(((i['price'] ?? 0) as num).toDouble() * ((i['quantity'] ?? 1) as num).toDouble()), style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
            const Divider(height: 24),

            // Pricing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: TextStyle(color: Colors.grey.shade600)),
                Text(_formatPrice(order.subtotal)),
              ],
            ),
            if (order.serviceFee > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Biaya Layanan', style: TextStyle(color: Colors.grey.shade600)),
                  Text(_formatPrice(order.serviceFee)),
                ],
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(_formatPrice(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 8),

            // Payment method
            Row(
              children: [
                const Icon(Icons.qr_code_2, size: 16, color: Color(0xFF1A73E8)),
                const SizedBox(width: 6),
                Text('Metode: ${order.paymentMethod}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 12),

            if (order.status == 'Menunggu Pembayaran' && order.qrString != null) ...[
              const Divider(height: 24),
              const Center(
                child: Text('Lanjutkan Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                    ],
                  ),
                  child: QrImageView(
                    data: order.qrString!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Scan QR code menggunakan aplikasi E-Wallet pilihanmu', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                  label: const Text('Cek Status Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    if (order.transactionId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID Transaksi tidak ditemukan')));
                      return;
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengecek status pembayaran...')));
                    
                    try {
                      final status = await LouvinService().checkTransactionStatus(order.transactionId!);
                      if (status == 'settled' || status == 'success') {
                         await _orderService.updateOrderStatus(order.id, 'Sedang Disiapkan');
                         if (ctx.mounted) Navigator.pop(ctx);
                         if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran berhasil! Pesanan diproses.'), backgroundColor: Colors.green));
                         }
                      } else {
                         if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status saat ini: $status'), backgroundColor: Colors.orange));
                         }
                      }
                    } catch (e) {
                       if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengecek: $e'), backgroundColor: Colors.red));
                       }
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ] else if (order.status == 'Menunggu Pembayaran') ...[
              const Divider(height: 24),
              const Center(
                child: Text('Pembayaran Gagal / Belum Dibuat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 18),
                  label: const Text('Buat Kode QRIS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          totalAmount: order.totalAmount,
                          stallId: order.stallId,
                          stallName: order.stallName,
                          existingOrder: order,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 20),
            ],

            if (order.status == 'Menunggu Pembayaran') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Batalkan Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: const Text('Apakah kamu yakin ingin membatalkan pesanan ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false), 
                            child: const Text('Tidak', style: TextStyle(color: Colors.grey))
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
                            onPressed: () => Navigator.pop(c, true), 
                            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white))
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      try {
                        await _orderService.updateOrderStatus(order.id, 'Dibatalkan');
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pesanan berhasil dibatalkan'),
                              backgroundColor: Colors.green,
                            )
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal membatalkan pesanan: $e'),
                              backgroundColor: Colors.red,
                            )
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Batalkan Pesanan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final itemsStr = order.items.map((i) => '${i['quantity']}x ${i['name']}').join(', ');
    final statusColor = _getStatusColor(order.status);
    final icon = _getStatusIcon(order.status);
    final isOngoing = order.status != 'Selesai' && order.status != 'Dibatalkan';

    return GestureDetector(
      onTap: () => _showOrderDetail(order),
      child: Container(
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
                          order.stallName,
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
                      Text(order.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Text(itemsStr, style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order.id.substring(0, 8).toUpperCase()} • ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                Text(_formatPrice(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOngoing ? AppTheme.primaryColor : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isOngoing ? Colors.transparent : AppTheme.primaryColor),
                  ),
                ),
                onPressed: () => _showOrderDetail(order),
                child: Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: isOngoing ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}