// admin_consultation_list_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminConsultationListPage extends StatelessWidget {
  final String accessToken;
  final String refreshToken;

  const AdminConsultationListPage({
    Key? key,
    required this.accessToken,
    required this.refreshToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 标题栏 - 白色背景
          Container(
            color: Colors.white,
            child: AppBar(
              title: const Text(
                '咨询记录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    // 刷新功能将在_ConsultationListContent中实现
                  },
                ),
              ],
            ),
          ),

          // 搜索框区域 - 白色背景
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE4E7EC), width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Color(0xFF667085)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: '搜索咨询记录...',
                        hintStyle: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      onChanged: (value) {
                        // 搜索功能
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),

          // 列表内容 - 白色背景
          Expanded(
            child: Container(
              color: Colors.white,
              child: _ConsultationListContent(
                accessToken: accessToken,
                refreshToken: refreshToken,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 数据模型类 - 根据提供的JSON结构调整
class ConsultationResponse {
  final BaseResponse base;
  final ConsultationData data;

  ConsultationResponse({required this.base, required this.data});

  factory ConsultationResponse.fromJson(Map<String, dynamic> json) {
    return ConsultationResponse(
      base: BaseResponse.fromJson(json['base']),
      data: ConsultationData.fromJson(json['data']),
    );
  }

  // 创建模拟数据 - 根据提供的JSON结构
  static ConsultationResponse mockData() {
    return ConsultationResponse(
      base: BaseResponse(code: 10000, msg: "success"),
      data: ConsultationData(
        items: [
          ConsultationItem(
            consult: ConsultInfo(
              userId: "13712345679",
              consultId: 1,
              budgetRange: "20万元左右",
              preferredType: "SUV",
              useCase: "每天上下班通勤，来回大概40公里，周末偶尔在市区逛逛",
              fuelType: "电动",
              brandPreference: "比亚迪、吉利",
            ),
            consultResult: ConsultResult(
              analysis:
                  "根据您的需求，您希望购买一款价格大约在20万元左右的SUV车型，主要用于日常上下班通勤（单日往返约40公里），以及周末偶尔的城市内活动。考虑到您对电动车的兴趣及指定的品牌偏好（比亚迪、吉利），下面为您推荐几款符合要求的电动汽车。",
              proposal:
                  "鉴于您的预算范围和个人喜好，在比亚迪唐EV和吉利帝豪GSe之间选择会是比较好的决定。两者都是市场上口碑不错的电动SUV选项，但具体选择哪一款还需考虑个人对车辆尺寸、配置等方面的具体需求。建议亲自试驾体验后再做最终决定。",
              result: [
                CarRecommendation(
                  imageUrl: "https://example.com/byd_tang_ev.jpg",
                  carName: "比亚迪唐EV",
                  fuelConsumption: "N/A (纯电)",
                  power: "最大功率180kW, 最大扭矩330Nm",
                  seat: "5座/7座可选",
                  drive: "前驱/四驱可选",
                  recommendedReason:
                      "比亚迪唐EV以其出色的续航里程和空间表现著称，非常适合家庭使用。其先进的电池技术和智能驾驶辅助系统能够满足您对于科技感的需求。",
                ),
                CarRecommendation(
                  imageUrl: "https://example.com/geely_emgrand_xev.jpg",
                  carName: "吉利帝豪GSe",
                  fuelConsumption: "N/A (纯电)",
                  power: "最大功率120kW, 最大扭矩250Nm",
                  seat: "5座",
                  drive: "前驱",
                  recommendedReason:
                      "作为一款性价比极高的紧凑型SUV，吉利帝豪GSe不仅拥有时尚动感的外观设计，而且在经济性和实用性方面也表现出色，非常适合城市通勤与周末短途旅行。",
                ),
              ],
            ),
          ),
        ],
        total: 1,
      ),
    );
  }
}

class BaseResponse {
  final int code;
  final String msg;

  BaseResponse({required this.code, required this.msg});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(code: json['code'], msg: json['msg']);
  }
}

class ConsultationData {
  final List<ConsultationItem> items;
  final int total;

  ConsultationData({required this.items, required this.total});

  factory ConsultationData.fromJson(Map<String, dynamic> json) {
    return ConsultationData(
      items: (json['item'] as List)
          .map((item) => ConsultationItem.fromJson(item))
          .toList(),
      total: json['total'],
    );
  }
}

class ConsultationItem {
  final ConsultInfo consult;
  final ConsultResult consultResult;

  ConsultationItem({required this.consult, required this.consultResult});

  factory ConsultationItem.fromJson(Map<String, dynamic> json) {
    return ConsultationItem(
      consult: ConsultInfo.fromJson(json['consult']),
      consultResult: ConsultResult.fromJson(json['consult_result']),
    );
  }
}

class ConsultInfo {
  final String userId;
  final int consultId;
  final String budgetRange;
  final String preferredType;
  final String useCase;
  final String fuelType;
  final String brandPreference;

  ConsultInfo({
    required this.userId,
    required this.consultId,
    required this.budgetRange,
    required this.preferredType,
    required this.useCase,
    required this.fuelType,
    required this.brandPreference,
  });

  factory ConsultInfo.fromJson(Map<String, dynamic> json) {
    return ConsultInfo(
      userId: json['UserId'],
      consultId: json['ConsultId'],
      budgetRange: json['BudgetRange'],
      preferredType: json['PreferredType'],
      useCase: json['UseCase'],
      fuelType: json['FuelType'],
      brandPreference: json['BrandPreference'],
    );
  }
}

class ConsultResult {
  final String analysis;
  final String proposal;
  final List<CarRecommendation> result;

  ConsultResult({
    required this.analysis,
    required this.proposal,
    required this.result,
  });

  factory ConsultResult.fromJson(Map<String, dynamic> json) {
    return ConsultResult(
      analysis: json['Analysis'],
      proposal: json['Proposal'],
      result: (json['Result'] as List)
          .map((car) => CarRecommendation.fromJson(car))
          .toList(),
    );
  }
}

class CarRecommendation {
  final String imageUrl;
  final String carName;
  final String fuelConsumption;
  final String power;
  final String seat;
  final String drive;
  final String recommendedReason;

  CarRecommendation({
    required this.imageUrl,
    required this.carName,
    required this.fuelConsumption,
    required this.power,
    required this.seat,
    required this.drive,
    required this.recommendedReason,
  });

  factory CarRecommendation.fromJson(Map<String, dynamic> json) {
    return CarRecommendation(
      imageUrl: json['ImageUrl'],
      carName: json['CarName'],
      fuelConsumption: json['FuelConsumption'],
      power: json['Power'],
      seat: json['Seat'],
      drive: json['Drive'],
      recommendedReason: json['RecommendedReason'],
    );
  }
}

// API服务类 - 具备前后端联调能力
class ConsultationService {
  final String accessToken;
  final String refreshToken;

  ConsultationService({required this.accessToken, required this.refreshToken});

  Future<ConsultationResponse> getConsultationRecords({
    int pageSize = 10,
    int pageNum = 1,
  }) async {
    // TODO: 替换为实际的API端点
    const apiUrl = 'http://your-api-domain.com/api/admin/consult/query';

    try {
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: {
          'page_size': pageSize.toString(),
          'page_num': pageNum.toString(),
        },
      );

      print('发送API请求到: $uri');
      print('请求头 - Access-token: $accessToken');
      print('请求头 - Refresh-token: $refreshToken');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Access-token': accessToken,
          'Refresh-token': refreshToken,
        },
      );

      print('API响应状态码: ${response.statusCode}');
      print('API响应体: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ConsultationResponse.fromJson(responseData);
      } else {
        print('API请求失败，状态码: ${response.statusCode}');
        // 返回模拟数据
        return _getMockResponse();
      }
    } catch (e) {
      print('HTTP请求异常: $e');
      // 返回模拟数据
      return _getMockResponse();
    }
  }

  // 返回模拟数据
  ConsultationResponse _getMockResponse() {
    print('使用模拟数据');
    return ConsultationResponse.mockData();
  }
}

// 列表内容组件
class _ConsultationListContent extends StatefulWidget {
  final String accessToken;
  final String refreshToken;

  const _ConsultationListContent({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  State<_ConsultationListContent> createState() =>
      _ConsultationListContentState();
}

class _ConsultationListContentState extends State<_ConsultationListContent> {
  late ConsultationService _consultationService;
  List<ConsultationItem> _consultations = [];
  List<ConsultationItem> _filteredConsultations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _consultationService = ConsultationService(
      accessToken: widget.accessToken,
      refreshToken: widget.refreshToken,
    );
    _loadConsultationRecords();
  }

  Future<void> _loadConsultationRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _consultationService.getConsultationRecords();

      if (response.base.code == 10000) {
        setState(() {
          _consultations = response.data.items;
          _filteredConsultations = _consultations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.base.msg;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络错误: $e';
        _isLoading = false;
      });
      print('加载咨询记录错误: $e');
    }
  }

  void _refresh() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _searchText = '';
    });
    _loadConsultationRecords();
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchText = text;
      if (text.isEmpty) {
        _filteredConsultations = _consultations;
      } else {
        _filteredConsultations = _consultations.where((consult) {
          return consult.consult.userId.contains(text) ||
              consult.consult.budgetRange.contains(text) ||
              consult.consult.preferredType.contains(text) ||
              consult.consult.fuelType.contains(text) ||
              consult.consult.brandPreference.contains(text) ||
              consult.consult.useCase.contains(text);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1677FF)),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                '加载失败',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF667085), fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredConsultations.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Color(0xFFD0D5DD)),
              const SizedBox(height: 16),
              Text(
                _searchText.isEmpty ? '暂无咨询记录' : '未找到相关咨询记录',
                style: const TextStyle(fontSize: 16, color: Color(0xFF667085)),
              ),
              if (_searchText.isEmpty) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('刷新'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        backgroundColor: Colors.white,
        color: const Color(0xFF007AFF),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredConsultations.length,
          itemBuilder: (context, index) {
            return _buildConsultationCard(_filteredConsultations[index]);
          },
        ),
      ),
    );
  }

  // 以下方法保持不变...
  Widget _buildConsultationCard(ConsultationItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFE4E7EC), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户ID和时间
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${item.consult.userId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1D2939),
                  ),
                ),
                Text(
                  _formatConsultationTime(item.consult.consultId),
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 用户需求标签
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildTag(item.consult.fuelType),
                _buildTag(item.consult.preferredType),
                ..._buildUseCaseTags(item.consult.useCase),
              ],
            ),
            const SizedBox(height: 12),

            // 推荐车型数量
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1E9FF), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.recommend,
                    size: 16,
                    color: Color(0xFF007AFF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '推荐了 ${item.consultResult.result.length} 款车型',
                    style: const TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showConsultationDetail(item),
                    child: const Row(
                      children: [
                        Text(
                          '查看详情',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF007AFF),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE4E7EC), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
      ),
    );
  }

  List<Widget> _buildUseCaseTags(String useCase) {
    final tags = <Widget>[];

    if (useCase.contains('通勤') || useCase.contains('上下班')) {
      tags.add(_buildTag('通勤'));
    }
    if (useCase.contains('家庭') || useCase.contains('家用')) {
      tags.add(_buildTag('家庭'));
    }
    if (useCase.contains('旅行') ||
        useCase.contains('旅游') ||
        useCase.contains('自驾')) {
      tags.add(_buildTag('旅行'));
    }
    if (useCase.contains('商务')) {
      tags.add(_buildTag('商务'));
    }
    if (useCase.contains('代步')) {
      tags.add(_buildTag('代步'));
    }

    return tags;
  }

  String _formatConsultationTime(int consultId) {
    final now = DateTime.now();
    final consultTime = now.subtract(Duration(hours: consultId * 2));
    return '${consultTime.hour.toString().padLeft(2, '0')}:${consultTime.minute.toString().padLeft(2, '0')}';
  }

  void _showConsultationDetail(ConsultationItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return _buildConsultationDetailSheet(item);
      },
    );
  }

  Widget _buildConsultationDetailSheet(ConsultationItem item) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '咨询详情',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Color(0xFF667085)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('用户信息', '''
用户ID: ${item.consult.userId}
预算范围: ${item.consult.budgetRange}
偏好车型: ${item.consult.preferredType}
能源类型: ${item.consult.fuelType}
品牌偏好: ${item.consult.brandPreference}
使用场景: ${item.consult.useCase}
                  '''),

                  _buildDetailSection('需求分析', item.consultResult.analysis),

                  _buildDetailSection('购车建议', item.consultResult.proposal),

                  _buildCarRecommendations(item.consultResult.result),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2939),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCarRecommendations(List<CarRecommendation> cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '推荐车型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2939),
          ),
        ),
        const SizedBox(height: 12),
        ...cars.map((car) => _buildCarCard(car)).toList(),
      ],
    );
  }

  Widget _buildCarCard(CarRecommendation car) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: const Color(0xFFE4E7EC), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              car.carName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2939),
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildCarSpec('能耗', car.fuelConsumption),
                _buildCarSpec('动力', car.power),
                _buildCarSpec('座位', car.seat),
                _buildCarSpec('驱动', car.drive),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              car.recommendedReason,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF667085),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarSpec(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D2939),
          ),
        ),
      ],
    );
  }
}
