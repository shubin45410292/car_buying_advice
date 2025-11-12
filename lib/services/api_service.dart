import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://204.152.192.27:8080';
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  /// ==========================
  /// 🟢 登录接口
  /// ==========================
  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/user/login')
        .replace(queryParameters: {'user_id': userId, 'password': password});

    print('📡 登录请求: $url');
    final response = await http.post(url, headers: jsonHeaders);
    print('📥 响应码: ${response.statusCode}');
    print('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ 登录成功则保存 token
      if (data['base']?['code'] == 10000) {
        final prefs = await SharedPreferences.getInstance();
        final token = data['data']?['token'] ?? '';
        await prefs.setString('token', token);
        await prefs.setString('user_id', userId);
      }

      return data;
    } else {
      throw Exception('登录失败: ${response.statusCode}');
    }
  }

  /// ==========================
  /// 🟡 注册接口
  /// ==========================
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

    print('📡 注册请求: $url');
    final response = await http.post(url, headers: jsonHeaders);
    print('📥 响应码: ${response.statusCode}');
    print('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('注册失败: ${response.statusCode}');
    }
  }

  /// ==========================
  /// 🔵 查询用户基本信息
  /// ==========================
  static Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('缺少 token，请重新登录');
    }

    final url = Uri.parse('$baseUrl/api/user/query/Info')
        .replace(queryParameters: {'user_id': userId});

    print('📡 查询用户信息请求: $url');
    final response = await http.get(url, headers: {
      ...jsonHeaders,
      'Authorization': 'Bearer $token', // ✅ 带上 token
    });

    print('📥 响应码: ${response.statusCode}');
    print('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('获取用户信息失败: ${response.statusCode}');
    }
  }

  /// ==========================
  /// 🟣 更新个人信息
  /// ==========================
  static Future<Map<String, dynamic>> updateUserInfo({
    required String userId,
    required String address,
    required String budgetMin,
    required String budgetMax,
    required String preferredType,
    required String preferredBrand,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('缺少 token，请重新登录');
    }

    final url = Uri.parse('$baseUrl/api/user/update/Info').replace(queryParameters: {
      'user_id': userId,
      'address': address,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'preferred_type': preferredType,
      'preferred_brand': preferredBrand,
    });

    print('📡 更新信息请求: $url');
    final response = await http.put(url, headers: {
      ...jsonHeaders,
      'Authorization': 'Bearer $token', // ✅ 带上 token
    });

    print('📥 响应码: ${response.statusCode}');
    print('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('更新个人信息失败: ${response.statusCode}');
    }
  }
}
