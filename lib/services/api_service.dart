import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {String? token}) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Error ${res.statusCode}');
    }
  }

  Future<dynamic> get(String path, {String? token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Error ${res.statusCode}');
    }
  }
}
