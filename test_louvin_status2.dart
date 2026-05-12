import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://api.louvin.dev/check-status/94c9eeac-d880-4033-8df7-083b69020c11');
  final apiKey = 'lv_6139f5a8c2234ff19a2d395d2286095c';
  final response = await http.get(url, headers: {'x-api-key': apiKey});
  print(response.body);
}
