import 'package:flutter/material.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  // 模拟数据：积分记录列表
  List<Map<String, String>> pointsRecords = [
    {'description': '分享查询结果', 'points': '+30', 'time': '11:44'},
    {'description': '兑换usb充电器', 'points': '-500', 'time': '2024-10-24'},
    {'description': '每日签到', 'points': '+5', 'time': '2024-10-23'},
    {'description': '完成车辆咨询', 'points': '+20', 'time': '2024-10-23'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分记录'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: pointsRecords.map((record) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${record['description']} ${record['points']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black, // 统一使用黑色
                      ),
                    ),
                    Text(
                      record['time']!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: '咨询',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '咨询记录'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: '积分中心'),
        ],
        currentIndex: 3,
        onTap: (index) {
          // 导航逻辑
          print('切换到tab: $index');
        },
      ),
    );
  }
}
