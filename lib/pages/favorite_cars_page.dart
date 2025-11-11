import 'package:flutter/material.dart';

class FavoriteCarsPage extends StatefulWidget {
  const FavoriteCarsPage({super.key});

  @override
  State<FavoriteCarsPage> createState() => _FavoriteCarsPageState();
}

class _FavoriteCarsPageState extends State<FavoriteCarsPage> {
  // 模拟收藏数据（可改为从后端加载）
  final List<Map<String, dynamic>> favoriteCars = [
    {
      'name': '丰田 RAV4 荣放',
      'subTitle': '2.5L 四驱精英',
      'price': '25.88万',
      'fuel': '油电混合',
      'power': '油电混合',
      'seats': '5座',
      'drive': '四驱',
      'consumption': '4.7L/100km',
      'reason':
          'RAV4荣放双擎采用丰田成熟的混合动力系统，油耗低、可靠性高、空间宽敞，非常适合家庭使用。',
      'tags': ['省油', '空间大', '可靠性高'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('收藏车型'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: favoriteCars.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteCars.length,
              itemBuilder: (context, index) {
                final car = favoriteCars[index];
                return _buildCarCard(
                  context,
                  name: car['name'],
                  subTitle: car['subTitle'],
                  price: car['price'],
                  fuel: car['fuel'],
                  power: car['power'],
                  seats: car['seats'],
                  drive: car['drive'],
                  consumption: car['consumption'],
                  reason: car['reason'],
                  tags: List<String>.from(car['tags']),
                );
              },
            ),
    );
  }

  /// 空状态（暂无收藏）
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Column(
          children: [
            Icon(Icons.directions_car_outlined,
                size: 80, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              '暂无收藏车辆',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 收藏卡片组件
  Widget _buildCarCard(
    BuildContext context, {
    required String name,
    required String subTitle,
    required String price,
    required String fuel,
    required String power,
    required String seats,
    required String drive,
    required String consumption,
    required String reason,
    required List<String> tags,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),

          // 标题 + 价格
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1677FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            subTitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 6),

          // 车辆信息
          Text(
            '油耗: $consumption   动力: $power   座位: $seats   驱动: $drive',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),

          const SizedBox(height: 10),

          // 推荐理由
          Text(
            '推荐理由：$reason',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),

          const SizedBox(height: 10),

          // 标签
          Wrap(
            spacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1677FF),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
