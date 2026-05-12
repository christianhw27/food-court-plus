import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/louvin_service.dart';
import '../../core/app_notification.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String stallId;
  final String stallName;
  final OrderModel? existingOrder;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.stallId,
    required this.stallName,
    this.existingOrder,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String? _qrisString;
  String? _errorMessage;
  OrderModel? _pendingOrder;

  @override
  void initState() {
    super.initState();
    _createOrderAndGenerateQris();
  }

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    return 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _createOrderAndGenerateQris() async {
    setState(() => _isProcessing = true);
    try {
      final user = await AuthService().currentUserData;
      if (user == null) throw Exception("User not found");

      String orderId;
      
      if (widget.existingOrder != null) {
        // Jika retry pembayaran untuk pesanan yang sudah ada
        orderId = widget.existingOrder!.id;
        _pendingOrder = widget.existingOrder;
      } else {
        // 1. Ambil data keranjang khusus untuk stall ini
        final stallItems = CartService().items.where((item) => item.food.stallId == widget.stallId).toList();
        final subtotal = stallItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
        
        final cartItems = stallItems.map((item) => {
          'foodId': item.food.id,
          'name': item.food.name,
          'price': item.food.price,
          'quantity': item.quantity,
        }).toList();

        // 2. Buat objek pesanan (Status awal: Menunggu Pembayaran)
        final order = OrderModel(
          id: '', // Di-generate oleh Firestore nanti
          buyerUid: user.uid,
          buyerName: user.name.isNotEmpty ? user.name : 'Pembeli',
          buyerPhone: user.phone,
          stallId: widget.stallId,
          stallName: widget.stallName,
          items: cartItems,
          subtotal: subtotal,
          serviceFee: 0,
          totalAmount: widget.totalAmount,
          status: 'Menunggu Pembayaran', 
          paymentMethod: 'QRIS',
          createdAt: DateTime.now(),
        );

        // 3. Simpan ke Firestore untuk dapat ID
        orderId = await OrderService().createOrder(order);
        _pendingOrder = order; // Simpan untuk referensi

        // 4. Kosongkan keranjang khusus untuk stan ini karena sudah jadi order
        CartService().clearCartByStall(widget.stallId);
      }

      // 5. Request QRIS ke Louvin
      final louvinService = LouvinService();
      // Tambahkan timestamp di belakang reference agar selalu unik jika di-retry
      final uniqueSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      final reference = 'FCP-${orderId.substring(0, 8).toUpperCase()}-$uniqueSuffix';
      
      try {
        final result = await louvinService.createQris(
          amount: widget.totalAmount.toInt(),
          customerName: user.name.isNotEmpty ? user.name : 'Pembeli',
          description: 'Pesanan di ${widget.stallName}',
          reference: reference,
        );

        if (mounted) {
          setState(() {
            _qrisString = result['qr_string'] as String?;
            _errorMessage = null;
          });
        }
        
        // Simpan info QRIS ke pesanan agar bisa ditampilkan lagi dari menu Pesanan Saya
        if (_qrisString != null && result['transaction_id'] != null) {
          await OrderService().updateOrderPaymentInfo(orderId, _qrisString!, result['transaction_id']);
        }
      } catch (louvinError) {
        // Jika Louvin error
        if (mounted) {
          setState(() {
            _errorMessage = louvinError.toString();
          });
        }
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal membuat pesanan: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _simulatePaymentSuccess() async {
    // Fungsi ini hanya untuk simulasi testing selama development
    // Pada produksi, status diupdate melalui Webhook dari server backend
    if (_pendingOrder == null) return;
    
    setState(() => _isProcessing = true);
    try {
      // Ambil ID pesanan terbaru karena _pendingOrder.id itu kosong di awal
      // Untuk demo ini, anggap berhasil aja
      Navigator.of(context).popUntil((route) => route.isFirst);
      AppNotification.showSuccess(context, 'Simulasi Pembayaran berhasil! Silakan cek menu Pesanan Saya (Berlangsung).');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pembayaran QRIS', style: TextStyle(color: AppTheme.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        // Kita matikan tombol back jika masih loading biar gak rusak flow
        leading: _isProcessing ? const SizedBox.shrink() : null, 
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                _formatPrice(widget.totalAmount),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    if (_isProcessing)
                      const Column(
                        children: [
                          CircularProgressIndicator(color: AppTheme.primaryColor),
                          SizedBox(height: 16),
                          Text('Menghubungkan ke Louvin...', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    else if (_errorMessage != null)
                      Column(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 50),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Pesanan kamu sudah tercatat dengan status "Menunggu Pembayaran".\nSilakan coba lagi atau hubungi admin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      )
                    else if (_qrisString != null)
                      Column(
                        children: [
                          // Render QR Code dari string QRIS Louvin
                          QrImageView(
                            data: _qrisString!,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Scan QR Code ini menggunakan\naplikasi e-wallet (Gopay, OVO, Dana) atau m-banking.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Tombol Simulasi (Hanya muncul jika kita ingin coba-coba)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _simulatePaymentSuccess,
                  child: const Text(
                    'Kembali ke Halaman Utama',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
