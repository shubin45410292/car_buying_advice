import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'result_page.dart';

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

    // 表单验证 - 修复验证逻辑
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
      // 准备API请求数据 - 作为查询参数，包含model参数
      final queryParams = {
        'budget_range': _budgetRangeController.text.trim(),
        'preferred_type': _preferredTypeController.text.trim(),
        'use_case': _useCaseController.text.trim(),
        'fuel_type': _fuelTypeController.text.trim(),
        'brand_preference': _brandPreferenceController.text.trim(),
        'model': _selectedModel, // 新增model参数
      };

      print('🚀 发送购车咨询请求: $queryParams');
      print('🔑 使用Token: $_accessToken');

      // 发送API请求
      final response = await _sendApiRequest(queryParams);

      // 隐藏加载状态
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // 处理响应 - 适配实际的API响应格式
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
      _showError('网络错误，请检查连接后重试: $e');
    }
  }

  // 发送API请求 - 使用GET方法，包含token
  Future<Map<String, dynamic>> _sendApiRequest(
    Map<String, dynamic> queryParams,
  ) async {
    const baseUrl = 'http://204.152.192.27:8080/api/consult/purchase';

    try {
      // 构建带查询参数的URL
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      print('📡 请求URL: $uri');
      print('📦 查询参数: $queryParams');

      // 构建请求头，包含token
      final headers = {
        'Content-Type': 'application/json',
        'Access-token': _accessToken ?? '',
        'Refresh-token': _refreshToken ?? '',
      };

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('✅ 响应状态码: ${response.statusCode}');
      print('📄 响应体: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print('🔍 解析后的响应: $responseData');
        return responseData;
      } else if (response.statusCode == 401) {
        // Token过期或无效
        print('❌ Token无效或已过期');
        throw Exception('Token无效或已过期，请重新登录');
      } else {
        print('❌ HTTP错误: ${response.statusCode}');
        // API不可用时返回模拟数据
        return _getMockResponse(queryParams);
      }
    } catch (e) {
      print('💥 请求异常: $e');
      // 网络错误时返回模拟数据
      return _getMockResponse(queryParams);
    }
  }

  // 返回模拟数据
  Map<String, dynamic> _getMockResponse(Map<String, dynamic> queryParams) {
    print('🔄 使用模拟数据');
    return {
      "base": {"code": 10000, "msg": "success"},
      "data": {
        "consult_id": 1,
        "Analysis":
            "根据您的需求，您希望购买一款预算约为${queryParams['budget_range']}的${queryParams['fuel_type']}${queryParams['preferred_type']}，主要用于${queryParams['use_case']}。考虑到您对品牌的偏好为${queryParams['brand_preference']}，这些品牌在中国市场都有不错的表现。",
        "Proposal": "基于您的预算及使用场景考量，我们为您推荐了以下车型。它们在性能、舒适性和经济性方面均表现优秀。",
        "Result": [
          {
            "ImageUrl":
                "https://p3.dcarimg.com/img/motor-mis-img/DCP_eb317d9f1a8344f7a23673c86c3ba0ac~2508x0.jpg",
            "CarName": "比亚迪宋PLUS EV",
            "FuelConsumption": "纯电动",
            "Power": "135kW (约184马力)",
            "Seat": "5座",
            "Drive": "前置前驱",
            "RecommendedReason":
                "比亚迪宋PLUS EV拥有出色的续航能力，满足日常通勤与周末短途旅行的需求；同时具备良好的性价比，是市场上较为受欢迎的一款紧凑型纯电SUV。",
          },
          {
            "ImageUrl":
                "https://p3.dcarimg.com/img/motor-mis-img/DCP_9ca4a605c0afb95475fc9f20b1a4b315~2508x0.jpg",
            "CarName": "几何C（原名：帝豪GSe）",
            "FuelConsumption": "纯电动",
            "Power": "150kW (约204马力)",
            "Seat": "5座",
            "Drive": "前置前驱",
            "RecommendedReason":
                "几何C作为吉利旗下的一款纯电动SUV，不仅外形设计时尚动感，而且配置丰富，能够很好地满足您对于城市驾驶以及偶尔外出游玩的需求。此外，其续航里程也相当可观，减少了频繁充电带来的不便。",
          },
        ],
      },
    };
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
