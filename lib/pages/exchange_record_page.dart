import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExchangeRecordPage extends StatefulWidget {
  final String name;
  final String phone;
  final String address;

  const ExchangeRecordPage({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  State<ExchangeRecordPage> createState() => _ExchangeRecordPageState();
}

class _ExchangeRecordPageState extends State<ExchangeRecordPage> {
  List<Map<String, dynamic>> records = [];
  bool isLoading = false;

  // 🔹 实际服务器地址
  final String _baseUrl = 'http://204.152.192.27:8080';

  // 🔹 模拟 Token，可换成你登录保存的
  final String _accessToken = 'your-access-token';
  final String _refreshToken = 'your-refresh-token';

  // 🔹 测试用户 ID（后续可替换为 SharedPreferences 或登录信息）
  final String _userId = '13712345679';

  @override
  void initState() {
    super.initState();
    fetchExchangeRecords();
  }

  Future<void> fetchExchangeRecords() async {
    setState(() => isLoading = true);

    final uri = Uri.parse('$_baseUrl/api/score/order/query')
        .replace(queryParameters: {'user_id': _userId});

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Access-token': _accessToken,
          'Refresh-token': _refreshToken,
        },
      );

      debugPrint('📡 请求URL: $uri');
      debugPrint('📄 状态码: ${response.statusCode}');
      debugPrint('📦 响应体: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final base = result['base'];
        final data = result['data'];

        if (base != null && base['code'] == 10000 && data != null) {
          final items = List<Map<String, dynamic>>.from(data['item'] ?? []);
          setState(() {
            records = items.isNotEmpty
                ? items
                : [
              {
                "gift_name": "暂无兑换记录",
                "orderTime": "-",
                "status": 0,
                "need_points": "-",
              }
            ];
          });
        } else {
          _showError(base?['msg'] ?? '数据异常');
        }
      } else {
        _showError('服务器异常：${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 网络异常: $e');
      _showError('网络错误，请检查连接');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('兑换记录'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
          ? const Center(child: Text('暂无兑换记录'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final item = records[index];
          final received = (item["status"] == 2);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["gift_name"] ?? '未知礼品',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Divider(
                    height: 24,
                    thickness: 1,
                    color: Color(0xFFE6E6E6)),
                Text('订单时间：${item["orderTime"] ?? "-"}',
                    style:
                    const TextStyle(fontSize: 15, height: 1.8)),
                Text('所需积分：${item["need_points"] ?? "-"}',
                    style:
                    const TextStyle(fontSize: 15, height: 1.8)),
                Text('收货状态：${received ? "已收货" : "未收货"}',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color:
                      received ? Colors.green : Colors.orange,
                    )),
                const SizedBox(height: 16),

                // ✅ 确认收货按钮（仅未收货时显示）
                if (!received)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('确认收货'),
                            content: const Text('是否确认已收到礼品？'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('取消'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF1677FF),
                                ),
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text(
                                  '确定',
                                  style:
                                  TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          setState(() {
                            records[index]["status"] = 2;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1677FF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '确认收货',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
