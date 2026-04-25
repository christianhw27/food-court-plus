import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class DokuService {
  // TODO: Masukkan Secret Key DOKU di sini saat sudah di-approve
  static const String _secretKey = 'SK-SIMULASI-XXX-XXX-XXX'; // GANTI INI NANTI
  static const String _clientId = 'BRN-0294-1741760978676';
  
  // URL Sandbox (Ubah ke api.doku.com jika sudah Production)
  static const String _baseUrl = 'https://api-sandbox.doku.com';
  static const String _qrisPath = '/orders/v1/qris';

  /// Fungsi untuk menggenerate QRIS string dari API DOKU Jokul
  Future<String?> generateQris({
    required String invoiceNumber,
    required int amount,
  }) async {
    // Jika Secret Key belum diubah, kita throw error agar dev tahu
    if (_secretKey.contains('SK-SIMULASI')) {
      throw Exception('Harap masukkan Secret Key DOKU di lib/services/doku_service.dart terlebih dahulu.');
    }

    final url = Uri.parse('$_baseUrl$_qrisPath');
    final requestId = const Uuid().v4();
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(RegExp(r'\.\d+Z$'), 'Z');

    final Map<String, dynamic> bodyPayload = {
      "order": {
        "invoice_number": invoiceNumber,
        "amount": amount,
      }
    };

    final String bodyString = jsonEncode(bodyPayload);

    // 1. Generate Digest: Base64(SHA256(Body))
    final digestBytes = sha256.convert(utf8.encode(bodyString));
    final digest = base64Encode(digestBytes.bytes);

    // 2. Generate Signature Component
    final signatureComponent = 
        "Client-Id:$_clientId\n"
        "Request-Id:$requestId\n"
        "Request-Timestamp:$timestamp\n"
        "Request-Target:$_qrisPath\n"
        "Digest:$digest";

    // 3. Generate HMAC-SHA256 Signature
    final hmacSha256 = Hmac(sha256, utf8.encode(_secretKey));
    final hmacBytes = hmacSha256.convert(utf8.encode(signatureComponent));
    final signature = "HMACSHA256=${base64Encode(hmacBytes.bytes)}";

    try {
      final response = await http.post(
        url,
        headers: {
          'Client-Id': _clientId,
          'Request-Id': requestId,
          'Request-Timestamp': timestamp,
          'Signature': signature,
          'Content-Type': 'application/json',
        },
        body: bodyString,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // String QRIS asli yang bisa dibuat jadi gambar QR Code
        return data['response']['qr_code'] as String?;
      } else {
        throw Exception('DOKU API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi DOKU: $e');
    }
  }
}
