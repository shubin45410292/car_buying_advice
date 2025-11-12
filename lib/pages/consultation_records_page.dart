import 'package:flutter/material.dart';

// 咨询记录数据模型
class ConsultationRecord {
  final String priceRange;
  final List<String> tags;
  final int recommendedCount;
  final String time;

  ConsultationRecord({
    required this.priceRange,
    required this.tags,
    required this.recommendedCount,
    required this.time,
  });
}

class ConsultationRecordsPage extends StatefulWidget {
  const ConsultationRecordsPage({super.key});

  @override
  State<ConsultationRecordsPage> createState() => _ConsultationRecordsPageState();
}

class _ConsultationRecordsPageState extends State<ConsultationRecordsPage> {
  // 模拟咨询记录数据
  List<ConsultationRecord> records = [
    ConsultationRecord(
      priceRange: '20-30 万',
      tags: ['混合动力', '通勤', '家庭'],
      recommendedCount: 2,
      time: '今天 10:23',
    ),
    ConsultationRecord(
      priceRange: '20-30 万',
      tags: ['混合动力', '通勤', '家庭'],
      recommendedCount: 2,
      time: '今天 10:23',
    ),
    // 可以添加更多模拟数据
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('咨询记录'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildRecordItem(record, context);
          },
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildRecordItem(ConsultationRecord record, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击事件处理，这里可以导航到详情页
        print('查看咨询详情');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.priceRange,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  record.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 标签部分
            Row(
              children: record.tags.map((tag) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1677FF),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              '推荐了 ${record.recommendedCount} 款车型',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
