import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'exchange_record_page.dart';

class ExchangeInfoPage extends StatefulWidget {
  const ExchangeInfoPage({super.key});

  @override
  State<ExchangeInfoPage> createState() => _ExchangeInfoPageState();
}

class _ExchangeInfoPageState extends State<ExchangeInfoPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addrCtrl = TextEditingController();

  bool isLoading = false;

  // 🔹 服务器和 token
  final String _baseUrl = 'http://204.152.192.27:8080';
  final String _accessToken = 'your-access-token';
  final String _refreshToken = 'your-refresh-token';

  // 示例礼品 ID（后续可由上个页面传入）
  final int _giftId = 1;
  final String _userId = '13712345679';

  Future<void> _submitExchange() async {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        addrCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整信息')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse('$_baseUrl/api/score/gift/purchase')
          .replace(queryParameters: {'gift_id': _giftId.toString()});

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Access-token': _accessToken,
          'Refresh-token': _refreshToken,
        },
      );

      debugPrint('🎯 兑换接口 URL: $uri');
      debugPrint('📦 状态码: ${response.statusCode}');
      debugPrint('📄 响应体: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final base = result['base'];

        if (base != null && base['code'] == 10000) {
          // ✅ 兑换成功
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('兑换成功！')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ExchangeRecordPage(
                name: nameCtrl.text,
                phone: phoneCtrl.text,
                address: addrCtrl.text,
              ),
            ),
          );
        } else {
          _showError(base?['msg'] ?? '兑换失败，请稍后重试');
        }
      } else {
        _showError('服务器错误：${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 网络异常: $e');
      _showError('网络异常，请稍后重试');
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
        title: const Text('兑换礼品'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildField('收货人姓名', nameCtrl),
                _buildField('收货人手机号', phoneCtrl,
                    keyboardType: TextInputType.phone),
                _buildField('收货人地址', addrCtrl),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitExchange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1677FF),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    '确认兑换',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 15),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
