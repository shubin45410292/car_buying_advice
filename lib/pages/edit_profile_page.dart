import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController brandController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController minBudgetController = TextEditingController();
  final TextEditingController maxBudgetController = TextEditingController();

  bool isLoading = false;

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final token = prefs.getString('token') ?? '';

    if (userId.isEmpty || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未找到登录信息，请重新登录')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.updateUserInfo(
        userId: userId,
        token: token, // ✅ 必传 Access-token
        preferredBrand: brandController.text,
        preferredType: typeController.text,
        address: addressController.text,
        budgetMin: int.tryParse(minBudgetController.text) ?? 0,
        budgetMax: int.tryParse(maxBudgetController.text) ?? 0,
      );

      final code = result['base']?['code'];
      if (code == 10000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('个人信息更新成功')),
        );
      } else {
        throw Exception(result['base']?['msg'] ?? '未知错误');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请求出错: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人信息'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildField('偏好的品牌：', brandController),
            _buildField('偏好的车型：', typeController),
            _buildField('奖品收货地址：', addressController),
            _buildField('最高预算（元）：', maxBudgetController,
                type: TextInputType.number),
            _buildField('最低预算（元）：', minBudgetController,
                type: TextInputType.number),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF1677FF),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('保存信息'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}