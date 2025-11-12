// 用户填写收货姓名、电话、地址，点击“确认兑换”进入兑换记录页。
import 'package:flutter/material.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField('收货人姓名', nameCtrl),
            _buildField('收货人手机号', phoneCtrl, keyboardType: TextInputType.phone),
            _buildField('收货人地址', addrCtrl),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty ||
                    phoneCtrl.text.isEmpty ||
                    addrCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写完整信息')),
                  );
                  return;
                }

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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1677FF), // 蓝色背景
                padding:
                const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              // ✅ 白色文字 + 加粗
              child: const Text(
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
