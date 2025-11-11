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
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  String? _selectedVehicleType;
  final TextEditingController _customVehicleTypeController = TextEditingController();
  final List<String> _selectedFuelTypes = [];
  
  // 品牌相关变量
  final List<String?> _selectedBrands = [null, null];
  final List<TextEditingController> _customBrandControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  final List<String> _selectedScenarios = [];
  final TextEditingController _otherNeedsController = TextEditingController();

  bool _isLoading = false;

  // 是否显示自定义车型输入框
  bool get _showCustomVehicleTypeInput => _selectedVehicleType == '其他';

  // 是否显示自定义品牌输入框
  List<bool> get _showCustomBrandInputs => [
    _selectedBrands[0] == '其他',
    _selectedBrands[1] == '其他',
  ];

  // 选项数据
  final List<String> _vehicleTypeOptions = ['SUV', '轿车', 'MPV', '其他'];
  
  final List<String> _brandOptions = [
    '比亚迪',
    '特斯拉',
    '丰田',
    '本田',
    '大众',
    '宝马',
    '奔驰',
    '奥迪',
    '其他'
  ];

  final List<String> _fuelTypeOptions = [
    '汽油',
    '柴油',
    '混合动力',
    '纯电动',
    '氢能源'
  ];

  final List<String> _scenarioOptions = [
    '通勤',
    '家庭',
    '商务',
    '其他'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('购车咨询'),
        backgroundColor: const Color(0xFF1677FF),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 购车预算范围 - 两个输入框
                _buildSectionTitle('购车预算范围 *'),
                _buildBudgetInputs(),
                
                const SizedBox(height: 24),
                
                // 偏好车型 - 4个框
                _buildSectionTitle('偏好车型 *'),
                _buildVehicleTypeGrid(),
                
                // 自定义车型输入框（当选择"其他"时显示）
                if (_showCustomVehicleTypeInput) ...[
                  const SizedBox(height: 12),
                  _buildCustomVehicleTypeInput(),
                ],
                
                const SizedBox(height: 24),
                
                // 主要使用场景
                _buildSectionTitle('主要使用场景 *'),
                _buildScenarioGrid(),
                
                const SizedBox(height: 24),
                
                // 燃料类型偏好 - 多选
                _buildSectionTitle('燃料类型偏好'),
                _buildFuelTypeGrid(),
                
                const SizedBox(height: 24),
                
                // 品牌偏好 - 两个下拉框
                _buildSectionTitle('品牌偏好'),
                _buildBrandSelection(),
                
                const SizedBox(height: 24),
                
                // 其他特殊需求
                _buildSectionTitle('其他特殊需求'),
                _buildOtherNeedsInput(),
                
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

  Widget _buildBudgetInputs() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minBudgetController,
            decoration: InputDecoration(
              hintText: '最低预算',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixText: '万',
              suffixStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _maxBudgetController,
            decoration: InputDecoration(
              hintText: '最高预算',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixText: '万',
              suffixStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
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
        final isSelected = _selectedVehicleType == option;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedVehicleType = option;
              if (option != '其他') {
                _customVehicleTypeController.clear();
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

  Widget _buildCustomVehicleTypeInput() {
    return TextField(
      controller: _customVehicleTypeController,
      decoration: InputDecoration(
        hintText: '请输入其他车型',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildScenarioGrid() {
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
        final isSelected = _selectedScenarios.contains(option);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedScenarios.contains(option)) {
                _selectedScenarios.remove(option);
              } else {
                _selectedScenarios.add(option);
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
        final isSelected = _selectedFuelTypes.contains(option);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedFuelTypes.contains(option)) {
                _selectedFuelTypes.remove(option);
              } else {
                _selectedFuelTypes.add(option);
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

  Widget _buildBrandSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSingleBrandDropdown(0),
        if (_showCustomBrandInputs[0]) ...[
          const SizedBox(height: 8),
          _buildCustomBrandInput(0),
        ],
        const SizedBox(height: 12),
        _buildSingleBrandDropdown(1),
        if (_showCustomBrandInputs[1]) ...[
          const SizedBox(height: 8),
          _buildCustomBrandInput(1),
        ],
      ],
    );
  }

  Widget _buildSingleBrandDropdown(int index) {
    return DropdownButtonFormField<String>(
      value: _selectedBrands[index],
      decoration: InputDecoration(
        hintText: '请选择品牌 ${index + 1}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _brandOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBrands[index] = newValue;
          if (newValue != '其他') {
            _customBrandControllers[index].clear();
          }
        });
      },
    );
  }

  Widget _buildCustomBrandInput(int index) {
    return TextField(
      controller: _customBrandControllers[index],
      decoration: InputDecoration(
        hintText: '请输入其他品牌名称 ${index + 1}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildOtherNeedsInput() {
    return TextField(
      controller: _otherNeedsController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: '请输入其他特殊需求...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(16),
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
    if (_minBudgetController.text.trim().isEmpty || _maxBudgetController.text.trim().isEmpty) {
      _showError('请输入购车预算范围');
      return;
    }
    
    final minBudget = double.tryParse(_minBudgetController.text.trim());
    final maxBudget = double.tryParse(_maxBudgetController.text.trim());
    
    if (minBudget == null || maxBudget == null) {
      _showError('请输入有效的预算数值');
      return;
    }
    
    if (minBudget >= maxBudget) {
      _showError('最高预算应大于最低预算');
      return;
    }
    
    if (_selectedVehicleType == null) {
      _showError('请选择偏好车型');
      return;
    }
    
    if (_selectedVehicleType == '其他' && _customVehicleTypeController.text.trim().isEmpty) {
      _showError('请输入其他车型名称');
      return;
    }
    
    if (_selectedScenarios.isEmpty) {
      _showError('请选择主要使用场景');
      return;
    }

    for (int i = 0; i < _selectedBrands.length; i++) {
      if (_selectedBrands[i] == '其他' && _customBrandControllers[i].text.trim().isEmpty) {
        _showError('请输入其他品牌名称 ${i + 1}');
        return;
      }
    }

    // 显示加载状态
    setState(() {
      _isLoading = true;
    });

    try {
      // 准备表单数据
      final formData = {
        'minBudget': _minBudgetController.text.trim(),
        'maxBudget': _maxBudgetController.text.trim(),
        'vehicleType': _selectedVehicleType == '其他' ? _customVehicleTypeController.text.trim() : _selectedVehicleType,
        'brands': _getSelectedBrands(),
        'fuelTypes': _selectedFuelTypes,
        'scenarios': _selectedScenarios,
        'otherNeeds': _otherNeedsController.text.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      print('发送给后端的表单数据: $formData');// 在控制台查看数据

      // 发送数据到后端（现在是模拟的）
      final response = await _sendDataToBackend(formData);
      
      // 隐藏加载状态
      setState(() {
        _isLoading = false;
      });

      // 处理响应
      if (response['base']['code'] == 10000) {
        // 成功，跳转到结果页面并传递后端数据
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            apiResponseData: response, // 传递后端响应数据
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

// 使用模拟数据
Future<Map<String, dynamic>> _sendDataToBackend(Map<String, dynamic> formData) async {
  // 模拟API调用延迟
  await Future.delayed(const Duration(seconds: 2));
  
  // 直接返回模拟数据
  return {
    "base": {
      "code": 10000,
      "msg": "success"
    },
    "data": {
      "Analysis": "根据您的预算${formData['minBudget']}-${formData['maxBudget']}万、偏好${formData['vehicleType']}车型、${formData['scenarios'].join(',')}使用场景，我们为您推荐了以下车型。",
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

  // // 发送数据到后端的方法
  // Future<Map<String, dynamic>> _sendDataToBackend(Map<String, dynamic> formData) async {
  //   // TODO: 替换为你的实际API端点
  //   const apiUrl = 'https://your-backend-api.com/car-recommendation';
    
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(formData),
  //     );

  //     print('后端响应状态码: ${response.statusCode}');
  //     print('后端响应体: ${response.body}');

  //     if (response.statusCode == 200) {
  //       // 解析 JSON 响应
  //       final responseData = jsonDecode(response.body);
  //       return responseData;
  //     } else {
  //       return {
  //         'base': {
  //           'code': response.statusCode,
  //           'msg': '服务器错误: ${response.statusCode}'
  //         }
  //       };
  //     }
  //   } catch (e) {
  //     print('HTTP请求异常: $e');
  //     return {
  //       'base': {
  //         'code': 50001,
  //         'msg': '网络连接失败: $e'
  //       }
  //     };
  //   }


  // }

  List<String> _getSelectedBrands() {
    final List<String> brands = [];
    for (int i = 0; i < _selectedBrands.length; i++) {
      if (_selectedBrands[i] != null) {
        if (_selectedBrands[i] == '其他') {
          final customBrand = _customBrandControllers[i].text.trim();
          if (customBrand.isNotEmpty) {
            brands.add(customBrand);
          }
        } else {
          brands.add(_selectedBrands[i]!);
        }
      }
    }
    return brands;
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
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _customVehicleTypeController.dispose();
    for (var controller in _customBrandControllers) {
      controller.dispose();
    }
    _otherNeedsController.dispose();
    super.dispose();
  }
}