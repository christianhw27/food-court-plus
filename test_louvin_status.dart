import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Try to GET transaction status
  final transactionId = '94c9eeac-d880-4033-8df7-083b69020c11'; // from previous test
  final apiKey = 'lv_6139f5a8c2234ff19a2d395d2286095c';
  
  final endpoints = [
    '/transaction/$transactionId',
    '/transactions/$transactionId',
    '/status/$transactionId',
    '/check-status/$transactionId'
  ];

  for (var ep in endpoints) {
    final url = Uri.parse('https://api.louvin.dev$ep');
    final response = await http.get(url, headers: {'x-api-key': apiKey});
    print('GET $ep => ${response.statusCode}');
    if (response.statusCode == 200) {
      print(response.body);
    }
  }
}
