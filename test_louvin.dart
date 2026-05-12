import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://api.louvin.dev/create-transaction');
  final body = {
    'amount': 32000,
    'payment_type': 'qris',
    'customer_name': 'Pembeli',
    'slug': 'foodcourt',
    'description': 'Pesanan di Stan Makan',
    'reference': 'FCP-12345678',
  };

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': 'lv_6139f5a8c2234ff19a2d395d2286095c',
    },
    body: jsonEncode(body),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');
}
