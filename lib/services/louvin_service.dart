import 'dart:convert';
import 'package:http/http.dart' as http;

class LouvinService {
  static const String _apiKey = 'lv_6139f5a8c2234ff19a2d395d2286095c';
  static const String _baseUrl = 'https://api.louvin.dev';

  /// Membuat transaksi QRIS via Louvin Payment Gateway
  /// Mengembalikan Map berisi qr_string dan transaction_id
  Future<Map<String, dynamic>> createTransaction({
    required int amount,
    required String customerName,
    String? customerEmail,
    String? description,
    String? reference,
    String paymentType = 'qris',
  }) async {
    final url = Uri.parse('$_baseUrl/create-transaction');

    final Map<String, dynamic> body = {
      'amount': amount,
      'payment_type': paymentType,
      'customer_name': customerName,
      'slug': 'foodcourt',
    };

    if (customerEmail != null) body['customer_email'] = customerEmail;
    if (description != null) body['description'] = description;
    if (reference != null) body['reference'] = reference;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return {
            'transaction_id': data['transaction']?['id'],
            'qr_string': data['payment']?['qr_string'] ?? data['payment']?['payment_number'],
            'order_id': data['payment']?['order_id'],
            'total_payment': data['payment']?['total_payment'],
            'expired_at': data['payment']?['expired_at'],
            'status': data['transaction']?['status'],
            'fee': data['transaction']?['fee'],
            'net_amount': data['transaction']?['net_amount'],
          };
        } else {
          throw Exception('Louvin: Transaksi gagal dibuat.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Louvin: API key tidak valid. Periksa konfigurasi.');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final errorMsg = data['message'] ?? data['details'] ?? data['error'] ?? 'Parameter tidak valid.';
        throw Exception('Louvin: $errorMsg');
      } else {
        throw Exception('Louvin API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal menghubungi Louvin: $e');
    }
  }

  /// Shortcut untuk membuat transaksi QRIS
  Future<Map<String, dynamic>> createQris({
    required int amount,
    required String customerName,
    String? description,
    String? reference,
  }) {
    return createTransaction(
      amount: amount,
      customerName: customerName,
      paymentType: 'qris',
      description: description,
      reference: reference,
    );
  }

  /// Cek status transaksi (berguna jika tidak pakai webhook)
  Future<String> checkTransactionStatus(String transactionId) async {
    final url = Uri.parse('$_baseUrl/check-status?id=$transactionId');
    try {
      final response = await http.get(url, headers: {'x-api-key': _apiKey});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['transaction']?['status'] ?? 'pending';
        }
      }
      return 'pending'; // Default jika error
    } catch (e) {
      return 'pending';
    }
  }
}
