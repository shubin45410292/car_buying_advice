import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://204.152.192.27:8080';

  /// 通用 POST 封装
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('📡 请求接口: $url');
    print('📨 请求体: $data');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('📥 状态码: ${response.statusCode}');
      print('📦 响应: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.body.isNotEmpty ? response.body : "无响应体"}');
      }
    } catch (e) {
      print('❌ 请求异常: $e');
      throw Exception('请求异常: $e');
    }
  }

  /// 登录接口（只传 user_id 和 password）
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    return await post('/api/user/login', {
      'user_id': username, // ✅ 按后端要求，只传 user_id
      'password': password,
    });
  }
}
