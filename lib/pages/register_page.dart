import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  Future<void> _register() async {
    final userId = userIdController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();

    if (userId.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请填写完整信息')));
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await ApiService.register(
        userId: userId,
        username: username,
        password: password,
        phone: phone,
      );
      final code = result['base']?['code'];

      if (code == 10000) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('注册成功，请返回登录')));
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注册失败：${result['base']?['msg'] ?? "未知错误"}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请求出错：$e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('用户注册', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField('账号（user_id）', userIdController),
            const SizedBox(height: 16),
            _buildField('用户名', usernameController),
            const SizedBox(height: 16),
            _buildField('手机号', phoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildField('密码', passwordController, obscure: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1677FF),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('注册',
                        style: TextStyle(fontSize: 17, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
