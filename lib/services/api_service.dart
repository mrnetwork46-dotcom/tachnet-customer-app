import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Existing TACH Billing Pro customer API.
  static const String baseUrl = 'https://tachnet.xyz/api/v1/customer';
  static const Duration timeout = Duration(seconds: 20);
  static const String _tokenKey = 'tach_customer_api_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException('সার্ভার থেকে সঠিক response পাওয়া যায়নি।');
    }

    if (decoded is Map<String, dynamic>) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }
      throw ApiException(
        decoded['message']?.toString() ?? 'Request ব্যর্থ হয়েছে (${response.statusCode})',
      );
    }
    throw ApiException('সার্ভারের response format সঠিক নয়।');
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {'Accept': 'application/json'},
          body: {
            'username': username.trim(),
            'password': password,
            'device_name': 'TACH Customer Android App',
          },
        )
        .timeout(timeout);

    final data = _decode(response);
    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw ApiException('লগইন response-এ token পাওয়া যায়নি।');
    }
    await _saveToken(token);
    return data;
  }

  static Future<Map<String, dynamic>> dashboard() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('আপনার session পাওয়া যায়নি। আবার লগইন করুন।');
    }

    final response = await http
        .get(
          Uri.parse('$baseUrl/dashboard'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(timeout);

    return _decode(response);
  }

  static Future<void> logout() async {
    final token = await getToken();
    try {
      if (token != null && token.isNotEmpty) {
        await http
            .post(
              Uri.parse('$baseUrl/logout'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(timeout);
      }
    } finally {
      await clearToken();
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
