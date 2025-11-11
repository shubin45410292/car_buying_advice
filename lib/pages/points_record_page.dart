// points_record_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PointsRecordPage extends StatefulWidget {
  const PointsRecordPage({Key? key}) : super(key: key);

  @override
  State<PointsRecordPage> createState() => _PointsRecordPageState();
}

class _PointsRecordPageState extends State<PointsRecordPage> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Token存储（需要从登录状态获取）
  String _accessToken = 'your-access-token'; // TODO: 从登录状态获取
  String _refreshToken = 'your-refresh-token'; // TODO: 从登录状态获取

  @override
  void initState() {
    super.initState();
    _fetchPointsData();
  }

  // 从API获取积分数据
  Future<void> _fetchPointsData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _fetchPointsFromAPI();

      if (response['base']['code'] == 10000) {
        final data = response['data'];
        final items = List<Map<String, dynamic>>.from(data['item'] ?? []);

        setState(() {
          _records = items;
        });
      } else {
        setState(() {
          _errorMessage = response['base']['msg'] ?? '获取数据失败';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络错误: $e';
        // 使用模拟数据作为备选
        _loadMockData();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 从API获取积分数据
  Future<Map<String, dynamic>> _fetchPointsFromAPI() async {
    const apiUrl = 'http://your-api-domain.com/api/score/user/query';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Access-token': _accessToken,
          'Refresh-token': _refreshToken,
        },
      );

      print('API响应状态码: ${response.statusCode}');
      print('API响应体: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'base': {
            'code': response.statusCode,
            'msg': '服务器错误: ${response.statusCode}',
          },
        };
      }
    } catch (e) {
      print('HTTP请求异常: $e');
      // 返回模拟数据
      return _getMockResponse();
    }
  }

  // 模拟API响应
  Map<String, dynamic> _getMockResponse() {
    return {
      "base": {"code": 10000, "msg": "success"},
      "data": {
        "item": [
          {
            "point_id": 1,
            "user_id": "13712345679",
            "points": 30,
            "reason": "分享查询结果",
            "created_at": "2024-01-15 11:44:00",
            "updated_at": "2024-01-15 11:44:00",
          },
          {
            "point_id": 2,
            "user_id": "13712345679",
            "points": -500,
            "reason": "兑换USB充电器",
            "created_at": "2024-10-24 14:30:00",
            "updated_at": "2024-10-24 14:30:00",
          },
        ],
        "num": 2,
        "sum": -470,
      },
    };
  }

  // 加载模拟数据
  void _loadMockData() {
    final mockResponse = _getMockResponse();
    final data = mockResponse['data'];
    final items = List<Map<String, dynamic>>.from(data['item'] ?? []);

    setState(() {
      _records = items;
    });
  }

  // 格式化时间显示 - 按照图中的格式
  String _formatTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime.replaceAll(' ', 'T'));

      // 如果是今天，显示时间（如：11:44）
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        // 显示完整日期（如：2024-10-24）
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // 如果解析失败，返回原始字符串
      return dateTime.length > 10 ? dateTime.substring(0, 10) : dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '积分记录',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage.isNotEmpty
          ? _buildError()
          : _buildRecordsList(),
    );
  }

  // 加载中状态
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('加载积分记录中...'),
        ],
      ),
    );
  }

  // 错误状态
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchPointsData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  // 记录列表 - 严格按照图中的样式
  Widget _buildRecordsList() {
    if (_records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无积分记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        final points = record['points'] as int;
        final isPositive = points > 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['reason'] ?? '未知',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(record['created_at'] ?? ''),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${points.toString()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
