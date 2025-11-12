import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ==============================
  // 基础配置
  // ==============================
  static const String baseUrl = 'http://204.152.192.27:8080';
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  /// 简单日志输出（替代 print）
  static void logged(String message) {
    // ignore: avoid_print
    print('[ApiService] $message');
  }

  // ==============================
  // 🟢 登录接口 user_id + password
  // ==============================
  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/user/login')
        .replace(queryParameters: {'user_id': userId, 'password': password});

    logged('📡 登录请求: $url');
    final response = await http.post(url, headers: jsonHeaders);

    logged('📥 响应码: ${response.statusCode}');
    logged('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 尝试保存 token
      final token = data['data']?['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_id', userId);
        logged('✅ 登录成功，token 已保存');
      }

      return data;
    } else {
      throw Exception('登录失败: ${response.statusCode}');
    }
  }

  // ==============================
  // 🟡 注册接口
  // ==============================
  static Future<Map<String, dynamic>> register({
    required String userId,
    required String username,
    required String password,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/api/user/register').replace(queryParameters: {
      'user_id': userId,
      'username': username,
      'password': password,
      'phone_number': phone,
    });

    logged('📡 注册请求: $url');
    final response = await http.post(url, headers: jsonHeaders);

    logged('📥 响应码: ${response.statusCode}');
    logged('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('注册失败: ${response.statusCode}');
    }
  }

  // ==============================
  // 🔵 更新个人信息接口
  // ==============================
  static Future<Map<String, dynamic>> updateUserInfo({
    required String userId,
    required String token,
    required String preferredBrand,
    required String preferredType,
    required String address,
    required int budgetMin,
    required int budgetMax,
  }) async {
    final url = Uri.parse('$baseUrl/api/user/update/Info'); // ✅ 注意 Info 大写

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Access-token': token, // ✅ Header 中携带 Access-token
      },
      body: jsonEncode({
        'user_id': userId,
        'preferred_brand': preferredBrand,
        'preferred_type': preferredType,
        'address': address,
        'budget_min': budgetMin,
        'budget_max': budgetMax,
      }),
    );

    logged('📡 PUT /api/user/update/Info');
    logged('📥 响应码: ${response.statusCode}');
    logged('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('更新个人信息失败: ${response.statusCode}');
    }
  }
}