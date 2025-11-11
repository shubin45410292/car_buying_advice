import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_page.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  // 表单状态变量
  final TextEditingController _budgetRangeController = TextEditingController();
  final TextEditingController _preferredTypeController = TextEditingController();
  final TextEditingController _useCaseController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _brandPreferenceController = TextEditingController();
  
  // 自定义输入控制器
  final TextEditingController _customUseCaseController = TextEditingController();
  final TextEditingController _customFuelTypeController = TextEditingController();

  // 选项数据
  final List<String> _vehicleTypeOptions = ['SUV', '轿车', 'MPV', '其他'];
  final List<String> _fuelTypeOptions = ['汽油', '柴油', '混合动力', '纯电动', '氢能源', '其他'];
  final List<String> _scenarioOptions = ['通勤', '家庭', '商务', '其他'];

  // 选择状态
  String? _selectedUseCase;
  bool _showCustomUseCaseInput = false;
  bool _showCustomFuelTypeInput = false;

  bool _isLoading = false;

  // Token存储
  String _accessToken = 'your-access-token';
  String _refreshToken = 'your-refresh-token';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '购车咨询',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true, // 标题居中
        backgroundColor: Colors.white, // 背景白色
        elevation: 0.5,
        foregroundColor: Colors.black, // 文字颜色黑色
        iconTheme: const IconThemeData(color: Colors.black), // 返回图标黑色
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: '请输入其他车型',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // 主要使用场景网格 - 四个框
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

  // 自定义使用场景输入
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  // 燃料类型网格 - 包含其他选项
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

  // 自定义燃料类型输入
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // 品牌偏好输入
  Widget _buildBrandPreferenceInput() {
    return TextField(
      controller: _brandPreferenceController,
      decoration: InputDecoration(
        hintText: '例如：比亚迪、吉利',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // 提交按钮
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1677FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _submitForm() async {
    // 表单验证
    if (_budgetRangeController.text.trim().isEmpty) {
      _showError('请输入预算范围');
      return;
    }
    
    if (_preferredTypeController.text.trim().isEmpty) {
      _showError('请选择偏好车型');
      return;
    }
    
    if (_preferredTypeController.text == '其他' && _preferredTypeController.text.trim().isEmpty) {
      _showError('请输入其他车型名称');
      return;
    }
    
    if (_useCaseController.text.trim().isEmpty) {
      _showError('请选择主要使用场景');
      return;
    }

    if (_selectedUseCase == '其他' && _customUseCaseController.text.trim().isEmpty) {
      _showError('请输入其他使用场景');
      return;
    }

    if (_fuelTypeController.text == '其他' && _customFuelTypeController.text.trim().isEmpty) {
      _showError('请输入其他燃料类型');
      return;
    }

    // 显示加载状态
    setState(() {
      _isLoading = true;
    });

    try {
      // 准备API请求数据
      final queryParams = {
        'budget_range': _budgetRangeController.text.trim(),
        'preferred_type': _preferredTypeController.text == '其他' 
            ? _preferredTypeController.text.trim() 
            : _preferredTypeController.text.trim(),
        'use_case': _useCaseController.text.trim(),
        'fuel_type': _fuelTypeController.text.trim(),
        'brand_preference': _brandPreferenceController.text.trim(),
      };

      print('发送给API的查询参数: $queryParams');

      // 发送API请求
      final response = await _sendApiRequest(queryParams);
      
      // 隐藏加载状态
      setState(() {
        _isLoading = false;
      });

      // 处理响应
      if (response['base']['code'] == 10000) {
        // 成功，跳转到结果页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              apiResponseData: response,
            ),
          ),
        );
      } else {
        _showError(response['base']['msg'] ?? '提交失败，请重试');
      }
    } catch (e) {
      // 隐藏加载状态
      setState(() {
        _isLoading = false;
      });
      _showError('网络错误，请检查连接后重试: $e');
    }
  }

  // 发送API请求
  Future<Map<String, dynamic>> _sendApiRequest(Map<String, dynamic> queryParams) async {
    // TODO: 替换为实际的API端点
    const apiUrl = 'http://your-api-domain.com/api/consult/purchase';
    
    try {
      final uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Access-token': _accessToken,
          'Refresh-token': _refreshToken,
        },
      );

      print('API响应状态码: ${response.statusCode}');
      print('API响应体: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'base': {
            'code': response.statusCode,
            'msg': '服务器错误: ${response.statusCode}'
          }
        };
      }
    } catch (e) {
      print('HTTP请求异常: $e');
      // 返回模拟数据
      return _getMockResponse(queryParams);
    }
  }

  // 返回模拟数据
  Map<String, dynamic> _getMockResponse(Map<String, dynamic> queryParams) {
    return {
      "base": {
        "code": 10000,
        "msg": "success"
      },
      "data": {
        "Analysis": "根据您的预算${queryParams['budget_range']}、偏好${queryParams['preferred_type']}车型、${queryParams['use_case']}使用场景，我们为您推荐了以下车型。",
        "Proposal": "基于您的需求，建议考虑以下车型。它们在性能、舒适性和经济性方面均表现优秀。",
        "Result": [
          {
            "ImageUrl": "https://img1.baidu.com/it/u=1626822570,2893215833&fm=253",
            "CarName": "比亚迪宋PLUS EV",
            "FuelConsumption": "纯电动",
            "Power": "135kW/184马力",
            "Seat": "5座",
            "Drive": "前驱",
            "RecommendedReason": "比亚迪宋PLUS EV是一款非常适合城市通勤与家庭使用的纯电动SUV。续航里程长，空间宽敞。"
          },
          {
            "ImageUrl": "https://img0.baidu.com/it/u=2037645185,3408279650&fm=253",
            "CarName": "吉利帝豪X EV",
            "FuelConsumption": "纯电动", 
            "Power": "120kW/163马力",
            "Seat": "5座",
            "Drive": "前驱",
            "RecommendedReason": "吉利帝豪X EV以其时尚动感的设计受到许多消费者的喜爱，性价比高。"
          }
        ]
      }
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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