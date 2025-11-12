import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'result_page.dart';
import '../services/api_service.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  // 表单状态变量
  final TextEditingController _budgetRangeController = TextEditingController();
  final TextEditingController _preferredTypeController =
      TextEditingController();
  final TextEditingController _useCaseController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _brandPreferenceController =
      TextEditingController();

  // 自定义输入控制器
  final TextEditingController _customUseCaseController =
      TextEditingController();
  final TextEditingController _customFuelTypeController =
      TextEditingController();

  // 选项数据
  final List<String> _vehicleTypeOptions = ['SUV', '轿车', 'MPV', '其他'];
  final List<String> _fuelTypeOptions = [
    '汽油',
    '柴油',
    '混合动力',
    '纯电动',
    '氢能源',
    '其他',
  ];
  final List<String> _scenarioOptions = ['通勤', '家庭', '商务', '其他'];

  // 模型选项
  final List<String> _modelOptions = ['qwen-plus', 'qwen3-max'];
  String _selectedModel = 'qwen-plus';

  // 选择状态
  String? _selectedUseCase;
  bool _showCustomUseCaseInput = false;
  bool _showCustomFuelTypeInput = false;

  bool _isLoading = false;

  // Token相关
  String? _accessToken;
  String? _refreshToken;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  // 从本地存储加载token
  Future<void> _loadTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _accessToken = prefs.getString('access_token');
        _refreshToken = prefs.getString('refresh_token');
      });
      print('🔑 加载的Token - Access: $_accessToken, Refresh: $_refreshToken');
    } catch (e) {
      print('❌ 加载token失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '购车咨询',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 预算范围
                _buildSectionTitle('预算范围 *'),
                _buildBudgetInput(),

                const SizedBox(height: 24),

                // 偏好车型
                _buildSectionTitle('偏好车型 *'),
                _buildVehicleTypeGrid(),

                // 自定义车型输入框
                if (_preferredTypeController.text == '其他') ...[
                  const SizedBox(height: 12),
                  _buildCustomVehicleTypeInput(),
                ],

                const SizedBox(height: 24),

                // 主要使用场景 - 四个框
                _buildSectionTitle('主要使用场景 *'),
                _buildUseCaseGrid(),

                // 自定义使用场景输入框
                if (_showCustomUseCaseInput) ...[
                  const SizedBox(height: 12),
                  _buildCustomUseCaseInput(),
                ],

                const SizedBox(height: 24),

                // 燃料类型偏好 - 包含其他选项
                _buildSectionTitle('燃料类型偏好'),
                _buildFuelTypeGrid(),

                // 自定义燃料类型输入框
                if (_showCustomFuelTypeInput) ...[
                  const SizedBox(height: 12),
                  _buildCustomFuelTypeInput(),
                ],

                const SizedBox(height: 24),

                // 品牌偏好
                _buildSectionTitle('品牌偏好'),
                _buildBrandPreferenceInput(),

                const SizedBox(height: 24),

                // 模型选择
                _buildSectionTitle('模型选择'),
                _buildModelSelection(),

                const SizedBox(height: 40),

                // 获取购车建议按钮
                _buildSubmitButton(),
              ],
            ),
          ),

          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1677FF)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBudgetInput() {
    return TextField(
      controller: _budgetRangeController,
      decoration: InputDecoration(
        hintText: '例如：20万元左右',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildVehicleTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: _vehicleTypeOptions.length,
      itemBuilder: (context, index) {
        final option = _vehicleTypeOptions[index];
        final isSelected = _preferredTypeController.text == option;

        return GestureDetector(
          onTap: () {
            setState(() {
              _preferredTypeController.text = option;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF1677FF) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Color(0xFF1677FF) : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomVehicleTypeInput() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _preferredTypeController.text = value;
        });
      },
      decoration: InputDecoration(
        hintText: '请输入其他车型',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildUseCaseGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3,
      ),
      itemCount: _scenarioOptions.length,
      itemBuilder: (context, index) {
        final option = _scenarioOptions[index];
        final isSelected = _selectedUseCase == option;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedUseCase = option;
              _useCaseController.text = option;
              _showCustomUseCaseInput = (option == '其他');
              if (option != '其他') {
                _customUseCaseController.clear();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF1677FF) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Color(0xFF1677FF) : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomUseCaseInput() {
    return TextField(
      controller: _customUseCaseController,
      onChanged: (value) {
        setState(() {
          _useCaseController.text = value;
        });
      },
      maxLines: 3,
      decoration: InputDecoration(
        hintText: '例如：每天上下班通勤，来回大概40公里，周末偶尔在市区逛逛',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFuelTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemCount: _fuelTypeOptions.length,
      itemBuilder: (context, index) {
        final option = _fuelTypeOptions[index];
        final isSelected = _fuelTypeController.text == option;

        return GestureDetector(
          onTap: () {
            setState(() {
              _fuelTypeController.text = option;
              _showCustomFuelTypeInput = (option == '其他');
              if (option != '其他') {
                _customFuelTypeController.clear();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF1677FF) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Color(0xFF1677FF) : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomFuelTypeInput() {
    return TextField(
      controller: _customFuelTypeController,
      onChanged: (value) {
        setState(() {
          _fuelTypeController.text = value;
        });
      },
      decoration: InputDecoration(
        hintText: '请输入其他燃料类型',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildBrandPreferenceInput() {
    return TextField(
      controller: _brandPreferenceController,
      decoration: InputDecoration(
        hintText: '例如：比亚迪、吉利',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  // 新增：模型选择组件
  Widget _buildModelSelection() {
    return Row(
      children: [
        Expanded(child: _buildModelOption('qwen-plus', '千问')),
        const SizedBox(width: 16),
        Expanded(child: _buildModelOption('qwen3-max', '千问Max')),
      ],
    );
  }

  Widget _buildModelOption(String value, String label) {
    final isSelected = _selectedModel == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModel = value;
        });
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1677FF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(0xFF1677FF) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1677FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '获取购车建议',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _submitForm() async {
    // 检查token是否存在
    if (_accessToken == null || _accessToken!.isEmpty) {
      _showError('请先登录获取访问令牌');
      return;
    }

    // 表单验证
    if (_budgetRangeController.text.trim().isEmpty) {
      _showError('请输入预算范围');
      return;
    }

    if (_preferredTypeController.text.trim().isEmpty) {
      _showError('请选择偏好车型');
      return;
    }

    // 修复：当选择"其他"车型时，应该检查自定义输入框的内容
    if (_preferredTypeController.text == '其他' &&
        _preferredTypeController.text.trim().isEmpty) {
      _showError('请输入其他车型名称');
      return;
    }

    if (_useCaseController.text.trim().isEmpty) {
      _showError('请选择主要使用场景');
      return;
    }

    // 修复：当选择"其他"使用场景时，应该检查自定义输入框的内容
    if (_selectedUseCase == '其他' &&
        _customUseCaseController.text.trim().isEmpty) {
      _showError('请输入其他使用场景');
      return;
    }

    // 修复：当选择"其他"燃料类型时，应该检查自定义输入框的内容
    if (_fuelTypeController.text == '其他' &&
        _customFuelTypeController.text.trim().isEmpty) {
      _showError('请输入其他燃料类型');
      return;
    }

    // 显示加载状态
    setState(() {
      _isLoading = true;
    });

    try {
      // 使用ApiService发送请求
      final response = await ApiService.purchaseConsult(
        accessToken: _accessToken!,
        refreshToken: _refreshToken ?? '',
        budgetRange: _budgetRangeController.text.trim(),
        preferredType: _preferredTypeController.text.trim(),
        useCase: _useCaseController.text.trim(),
        fuelType: _fuelTypeController.text.trim(),
        brandPreference: _brandPreferenceController.text.trim(),
        model: _selectedModel,
      );

      // 隐藏加载状态
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // 处理响应
      bool isSuccess = false;
      String? errorMsg;

      // 检查API响应格式
      if (response.containsKey('base')) {
        // 格式1: 有base层级
        final code = response['base']?['code'];
        isSuccess = code == 10000 || code == 200;
        errorMsg = response['base']?['msg'];
      } else if (response.containsKey('code')) {
        // 格式2: 直接code在顶层
        final code = response['code'];
        isSuccess = code == 10000 || code == 200;
        errorMsg = response['msg'] ?? response['message'];
      }

      if (isSuccess) {
        // 成功，跳转到结果页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(apiResponseData: response),
          ),
        );
      } else {
        _showError(errorMsg ?? '提交失败，请重试');
      }
    } catch (e) {
      // 隐藏加载状态
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _showError('请求出错: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _budgetRangeController.dispose();
    _preferredTypeController.dispose();
    _useCaseController.dispose();
    _fuelTypeController.dispose();
    _brandPreferenceController.dispose();
    _customUseCaseController.dispose();
    _customFuelTypeController.dispose();
    super.dispose();
  }
}
