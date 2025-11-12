import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController budgetMinController = TextEditingController();
  final TextEditingController budgetMaxController = TextEditingController();
  final TextEditingController preferredTypeController = TextEditingController();
  final TextEditingController preferredBrandController =
      TextEditingController();

  bool isLoading = false;

  Future<void> _submitUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final token = prefs.getString('access_token') ?? '';

    if (userId.isEmpty || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录再编辑资料')),
      );
      return;
    }

    final address = addressController.text.trim();
    final min = int.tryParse(budgetMinController.text.trim()) ?? 0;
    final max = int.tryParse(budgetMaxController.text.trim()) ?? 0;
    final type = preferredTypeController.text.trim();
    final brand = preferredBrandController.text.trim();

    if (address.isEmpty ||
        type.isEmpty ||
        brand.isEmpty ||
        min <= 0 ||
        max <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整资料')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.updateUserInfo(
        userId: userId,
        token: token,
        preferredBrand: brand,
        preferredType: type,
        address: address,
        budgetMin: min,
        budgetMax: max,
      );

      if (result['base']?['code'] == 10000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 资料更新成功')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '❌ 更新失败：${result['base']?['msg'] ?? "服务器未返回错误信息"}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请求出错：$e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          '编辑个人资料',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            _buildTextField('地址', '请输入您的居住地址', addressController),
            const SizedBox(height: 16),
            _buildTextField('预算最小值', '例如 10000', budgetMinController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('预算最大值', '例如 100000', budgetMaxController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('偏好车型', '例如 SUV、轿车', preferredTypeController),
            const SizedBox(height: 16),
            _buildTextField('品牌偏好', '例如 比亚迪、吉利', preferredBrandController),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1677FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '保存修改',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$label ',
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
              const TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
