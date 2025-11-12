// admin_consultation_list_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminConsultationListPage extends StatefulWidget {
  final String accessToken;
  final String refreshToken;

  const AdminConsultationListPage({
    Key? key,
    required this.accessToken,
    required this.refreshToken,
  }) : super(key: key);

  @override
  State<AdminConsultationListPage> createState() =>
      _AdminConsultationListPageState();
}

class _AdminConsultationListPageState extends State<AdminConsultationListPage> {
  final GlobalKey<_ConsultationListContentState> _listContentKey = GlobalKey();

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
                    _listContentKey.currentState?._refresh();
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
                        _listContentKey.currentState?._onSearchTextChanged(
                          value,
                        );
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
                key: _listContentKey,
                accessToken: widget.accessToken,
                refreshToken: widget.refreshToken,
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
  static ConsultationResponse mockData({int pageNum = 1}) {
    // 根据页码生成不同的模拟数据
    final items = List.generate(5, (index) {
      final id = (pageNum - 1) * 5 + index + 1;
      return ConsultationItem(
        consult: ConsultInfo(
          userId: "13712345${679 + id}",
          consultId: id,
          budgetRange: "${15 + id}万元左右",
          preferredType: index % 3 == 0
              ? "SUV"
              : index % 3 == 1
              ? "轿车"
              : "MPV",
          useCase: index % 2 == 0 ? "每天上下班通勤" : "家庭使用，周末出游",
          fuelType: index % 4 == 0
              ? "电动"
              : index % 4 == 1
              ? "混合动力"
              : index % 4 == 2
              ? "汽油"
              : "柴油",
          brandPreference: index % 2 == 0 ? "比亚迪、吉利" : "特斯拉、蔚来",
        ),
        consultResult: ConsultResult(
          analysis: "根据用户需求进行的详细分析...",
          proposal: "基于预算和使用场景的专业建议...",
          result: List.generate(
            2,
            (carIndex) => CarRecommendation(
              imageUrl: "https://example.com/car${carIndex + 1}.jpg",
              carName: carIndex == 0 ? "比亚迪唐EV" : "吉利帝豪GSe",
              fuelConsumption: "N/A (纯电)",
              power: carIndex == 0
                  ? "最大功率180kW, 最大扭矩330Nm"
                  : "最大功率120kW, 最大扭矩250Nm",
              seat: carIndex == 0 ? "5座/7座可选" : "5座",
              drive: carIndex == 0 ? "前驱/四驱可选" : "前驱",
              recommendedReason: carIndex == 0
                  ? "比亚迪唐EV以其出色的续航里程和空间表现著称，非常适合家庭使用。"
                  : "吉利帝豪GSe不仅拥有时尚动感的外观设计，而且在经济性和实用性方面也表现出色。",
            ),
          ),
        ),
      );
    });

    return ConsultationResponse(
      base: BaseResponse(code: 10000, msg: "success"),
      data: ConsultationData(
        items: items,
        total: 15, // 模拟总记录数
      ),
    );
  }
}

class BaseResponse {
  final int code;
  final String msg;

  BaseResponse({required this.code, required this.msg});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(code: json['code'] ?? 0, msg: json['msg'] ?? '');
  }
}

class ConsultationData {
  final List<ConsultationItem> items;
  final int total;

  ConsultationData({required this.items, required this.total});

  factory ConsultationData.fromJson(Map<String, dynamic> json) {
    return ConsultationData(
      items: (json['item'] as List? ?? [])
          .map((item) => ConsultationItem.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
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
      userId: json['UserId'] ?? '',
      consultId: json['ConsultId'] ?? 0,
      budgetRange: json['BudgetRange'] ?? '',
      preferredType: json['PreferredType'] ?? '',
      useCase: json['UseCase'] ?? '',
      fuelType: json['FuelType'] ?? '',
      brandPreference: json['BrandPreference'] ?? '',
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
      analysis: json['Analysis'] ?? '',
      proposal: json['Proposal'] ?? '',
      result: (json['Result'] as List? ?? [])
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
      imageUrl: json['ImageUrl'] ?? '',
      carName: json['CarName'] ?? '',
      fuelConsumption: json['FuelConsumption'] ?? '',
      power: json['Power'] ?? '',
      seat: json['Seat'] ?? '',
      drive: json['Drive'] ?? '',
      recommendedReason: json['RecommendedReason'] ?? '',
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
    const apiUrl = 'http://204.152.192.27:8080/api/admin/consult/query';

    try {
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: {
          'page_size': pageSize.toString(),
          'page_num': pageNum.toString(),
        },
      );

      print('📡 发送API请求到: $uri');
      print('🔑 请求头 - Access-token: $accessToken');
      print('🔑 请求头 - Refresh-token: $refreshToken');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Access-token': accessToken,
              'Refresh-token': refreshToken,
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📥 API响应状态码: ${response.statusCode}');
      print('📦 API响应体: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));

        // 检查业务状态码
        if (responseData['base']?['code'] == 10000) {
          return ConsultationResponse.fromJson(responseData);
        } else {
          throw Exception('业务错误: ${responseData['base']?['msg']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token无效或已过期');
      } else if (response.statusCode == 403) {
        throw Exception('无权限访问');
      } else {
        throw Exception('HTTP错误: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 HTTP请求异常: $e');
      // 返回模拟数据
      return _getMockResponse(pageNum: pageNum);
    }
  }

  // 返回模拟数据
  ConsultationResponse _getMockResponse({int pageNum = 1}) {
    print('🔄 使用模拟数据，页码: $pageNum');
    return ConsultationResponse.mockData(pageNum: pageNum);
  }
}

// 列表内容组件
class _ConsultationListContent extends StatefulWidget {
  final String accessToken;
  final String refreshToken;

  const _ConsultationListContent({
    Key? key,
    required this.accessToken,
    required this.refreshToken,
  }) : super(key: key);

  @override
  State<_ConsultationListContent> createState() =>
      _ConsultationListContentState();
}

class _ConsultationListContentState extends State<_ConsultationListContent> {
  late ConsultationService _consultationService;
  List<ConsultationItem> _consultations = [];
  List<ConsultationItem> _filteredConsultations = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  String _searchText = '';

  // 分页相关状态
  int _currentPage = 1;
  final int _pageSize = 10; // 固定每页显示10条记录
  int _totalRecords = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _consultationService = ConsultationService(
      accessToken: widget.accessToken,
      refreshToken: widget.refreshToken,
    );
    _loadConsultationRecords(pageNum: 1);
  }

  Future<void> _loadConsultationRecords({
    int pageNum = 1,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        setState(() {
          _isLoadingMore = true;
        });
      } else {
        setState(() {
          _isLoading = true;
          _errorMessage = '';
        });
      }

      final response = await _consultationService.getConsultationRecords(
        pageSize: _pageSize,
        pageNum: pageNum,
      );

      if (response.base.code == 10000) {
        setState(() {
          if (loadMore) {
            // 加载更多，追加数据
            _consultations.addAll(response.data.items);
          } else {
            // 重新加载，替换数据
            _consultations = response.data.items;
            _currentPage = pageNum;
          }
          _filteredConsultations = _consultations;
          _totalRecords = response.data.total;
          _hasMore = _consultations.length < _totalRecords;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _errorMessage = response.base.msg;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络错误: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
      print('加载咨询记录错误: $e');
    }
  }

  void _refresh() {
    setState(() {
      _searchText = '';
    });
    _loadConsultationRecords(pageNum: 1);
  }

  void _loadNextPage() {
    if (!_isLoadingMore && _hasMore) {
      _loadConsultationRecords(pageNum: _currentPage + 1, loadMore: true);
    }
  }

  void _loadPage(int pageNum) {
    _loadConsultationRecords(pageNum: pageNum);
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchText = text;
      if (text.isEmpty) {
        _filteredConsultations = _consultations;
      } else {
        _filteredConsultations = _consultations.where((consult) {
          return consult.consult.userId.toLowerCase().contains(
                text.toLowerCase(),
              ) ||
              consult.consult.budgetRange.toLowerCase().contains(
                text.toLowerCase(),
              ) ||
              consult.consult.preferredType.toLowerCase().contains(
                text.toLowerCase(),
              ) ||
              consult.consult.fuelType.toLowerCase().contains(
                text.toLowerCase(),
              ) ||
              consult.consult.brandPreference.toLowerCase().contains(
                text.toLowerCase(),
              ) ||
              consult.consult.useCase.toLowerCase().contains(
                text.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentPage == 1) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1677FF)),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _currentPage == 1) {
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

    final totalPages = (_totalRecords / _pageSize).ceil();
    final showPagination = totalPages > 1 && _searchText.isEmpty;

    return Column(
      children: [
        // 列表内容
        Expanded(
          child: Container(
            color: Colors.white,
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              backgroundColor: Colors.white,
              color: const Color(0xFF007AFF),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount:
                    _filteredConsultations.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _filteredConsultations.length &&
                      _isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1677FF),
                          ),
                        ),
                      ),
                    );
                  }

                  if (index == _filteredConsultations.length - 5 &&
                      _hasMore &&
                      _searchText.isEmpty) {
                    // 滑动到底部前5个item时自动加载更多
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadNextPage();
                    });
                  }

                  return _buildConsultationCard(_filteredConsultations[index]);
                },
              ),
            ),
          ),
        ),

        // 分页控件
        if (showPagination) _buildPagination(totalPages),
      ],
    );
  }

  // 构建分页控件
  Widget _buildPagination(int totalPages) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 上一页按钮
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            onPressed: _currentPage > 1
                ? () => _loadPage(_currentPage - 1)
                : null,
            color: _currentPage > 1 ? const Color(0xFF1677FF) : Colors.grey,
          ),

          const SizedBox(width: 8),

          // 页码显示
          Text(
            '第 $_currentPage 页 / 共 $totalPages 页',
            style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
          ),

          const SizedBox(width: 8),

          // 下一页按钮
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 24),
            onPressed: _currentPage < totalPages
                ? () => _loadPage(_currentPage + 1)
                : null,
            color: _currentPage < totalPages
                ? const Color(0xFF1677FF)
                : Colors.grey,
          ),

          const SizedBox(width: 16),

          // 总记录数
          Text(
            '共 $_totalRecords 条记录',
            style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }

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
                  '用户: ${item.consult.userId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1D2939),
                  ),
                ),
                Text(
                  '咨询ID: ${item.consult.consultId}',
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
咨询ID: ${item.consult.consultId}
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
            content.trim(),
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
