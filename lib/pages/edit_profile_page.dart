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
  final TextEditingController modelController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController maxBudgetController = TextEditingController();
  final TextEditingController minBudgetController = TextEditingController();

  bool isLoading = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// ✅ 从服务器加载个人信息
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('user_id') ?? '';

      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未登录，请重新登录')),
        );
        Navigator.pop(context);
        return;
      }

      final result = await ApiService.getUserInfo(userId);
      final data = result['data'];

      if (data != null) {
        setState(() {
          brandController.text = data['preferred_brand'] ?? '';
          modelController.text = data['preferred_type'] ?? '';
          addressController.text = data['address'] ?? '';
          maxBudgetController.text = data['budget_max']?.toString() ?? '';
          minBudgetController.text = data['budget_min']?.toString() ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载信息失败：$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ 保存信息（提交到后端）
  Future<void> _saveProfile() async {
    if (userId.isEmpty) return;

    try {
      setState(() => isLoading = true);

      final result = await ApiService.updateUserInfo(
        userId: userId,
        address: addressController.text,
        budgetMin: minBudgetController.text,
        budgetMax: maxBudgetController.text,
        preferredType: modelController.text,
        preferredBrand: brandController.text,
      );

      final code = result['base']?['code'];

      if (code == 10000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('个人信息已保存')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：${result['base']?['msg'] ?? "未知错误"}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存出错：$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('编辑个人信息'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('偏好的品牌：', brandController),
                  const SizedBox(height: 14),
                  _buildTextField('偏好的车型：', modelController),
                  const SizedBox(height: 14),
                  _buildTextField('奖品收货地址：', addressController),
                  const SizedBox(height: 14),
                  _buildTextField('最高预算：', maxBudgetController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 14),
                  _buildTextField('最低预算：', minBudgetController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1677FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                '保存信息',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// 通用输入框组件
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
