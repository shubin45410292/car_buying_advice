import 'package:flutter/material.dart';

class ExchangeHistoryPage extends StatelessWidget {
  const ExchangeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('兑换记录'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHistoryCard('USB 充电器', '2024-10-24', '2187665798880', '未收货'),
          _buildHistoryCard('空气净化器', '2024-10-10', '2198765543210', '已收货'),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
      String item, String date, String code, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('兑换日期：$date', style: const TextStyle(color: Colors.grey)),
            Text('快递单号：$code', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('状态：$status',
                    style: TextStyle(
                        color:
                            status == '已收货' ? Colors.green : Colors.orange)),
                if (status == '未收货')
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1677FF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('确认收货',
                        style: TextStyle(color: Colors.white)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
