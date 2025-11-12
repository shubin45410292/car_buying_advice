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
    final url = Uri.parse(
      '$baseUrl/api/user/login',
    ).replace(queryParameters: {'user_id': userId, 'password': password});

    logged('📡 登录请求: $url');
    final response = await http.post(url, headers: jsonHeaders);

    logged('📥 响应码: ${response.statusCode}');
    logged('📦 内容: ${response.body}');

    // ✅ 提取响应头中的 tokens - 兼容大小写
    final accessToken =
        response.headers['access-token'] ??
        response.headers['Access-Token'] ??
        '';
    final refreshToken =
        response.headers['refresh-token'] ??
        response.headers['Refresh-Token'] ??
        '';

    logged('🔑 Access-Token: $accessToken');
    logged('🔄 Refresh-Token: $refreshToken');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ 将响应头和响应体合并返回
      return {
        'base': data['base'],
        'data': data['data'],
        'headers': {'access-token': accessToken, 'refresh-token': refreshToken},
      };
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
    final url = Uri.parse('$baseUrl/api/user/register').replace(
      queryParameters: {
        'user_id': userId,
        'username': username,
        'password': password,
        'phone_number': phone,
      },
    );

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

  // ==============================
  // 🟣 购车咨询接口
  // ==============================
  static Future<Map<String, dynamic>> purchaseConsult({
    required String accessToken,
    required String refreshToken,
    required String budgetRange,
    required String preferredType,
    required String useCase,
    required String fuelType,
    required String brandPreference,
    required String model,
  }) async {
    final url = Uri.parse('$baseUrl/api/consult/purchase').replace(
      queryParameters: {
        'budget_range': budgetRange,
        'preferred_type': preferredType,
        'use_casecase': useCase,
        'fuel_type': fuelType,
        'brand_preference': brandPreference,
        'model': model,
      },
    );

    logged('📡 购车咨询请求: $url');

    final headers = {
      'Content-Type': 'application/json',
      'Access-token': accessToken,
      'Refresh-token': refreshToken,
    };

    final response = await http.get(url, headers: headers);

    logged('📥 响应码: ${response.statusCode}');
    logged('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Token无效或已过期，请重新登录');
    } else {
      throw Exception('购车咨询失败: ${response.statusCode}');
    }
  }

  // ==============================
  // 🟠 查询咨询记录接口
  // ==============================
  static Future<Map<String, dynamic>> getConsultHistory({
    required String accessToken,
    required String refreshToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/consult/history');

    logged('📡 查询咨询记录请求: $url');

    final headers = {
      'Content-Type': 'application/json',
      'Access-token': accessToken,
      'Refresh-token': refreshToken,
    };

    final response = await http.get(url, headers: headers);

    logged('📥 响应码: ${response.statusCode}');
    logged('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Token无效或已过期，请重新登录');
    } else {
      throw Exception('查询咨询记录失败: ${response.statusCode}');
    }
  }

  // ==============================
  // 🔶 查看用户积分接口
  // ==============================
  static Future<Map<String, dynamic>> getUserPoints({
    required String accessToken,
    required String refreshToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/points/user');

    logged('📡 查看用户积分请求: $url');

    final headers = {
      'Content-Type': 'application/json',
      'Access-token': accessToken,
      'Refresh-token': refreshToken,
    };

    final response = await http.get(url, headers: headers);

    logged('📥 响应码: ${response.statusCode}');
    logged('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Token无效或已过期，请重新登录');
    } else {
      throw Exception('查看用户积分失败: ${response.statusCode}');
    }
  }

  // ==============================
  // 🟪 提供反馈接口
  // ==============================
  static Future<Map<String, dynamic>> submitFeedback({
    required String accessToken,
    required String refreshToken,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/api/feedback/submit');

    logged('📡 提交反馈请求: $url');

    final headers = {
      'Content-Type': 'application/json',
      'Access-token': accessToken,
      'Refresh-token': refreshToken,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'content': content}),
    );

    logged('📥 响应码: ${response.statusCode}');
    logged('📦 内容: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Token无效或已过期，请重新登录');
    } else {
      throw Exception('提交反馈失败: ${response.statusCode}');
    }
  }
}
