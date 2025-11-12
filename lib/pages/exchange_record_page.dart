import 'package:flutter/material.dart';

class ExchangeRecordPage extends StatefulWidget {
  final String name;
  final String phone;
  final String address;

  const ExchangeRecordPage({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  State<ExchangeRecordPage> createState() => _ExchangeRecordPageState();
}

class _ExchangeRecordPageState extends State<ExchangeRecordPage> {
  /// 假设未来会有多个兑换记录
  final List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();

    // 模拟：添加一条默认兑换记录
    records.add({
      "title": "USB 充电器",
      "express": "2187666798980",
      "received": false,
      "name": widget.name,
      "phone": widget.phone,
      "address": widget.address,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('兑换记录'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final item = records[index];
          final received = item["received"] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Divider(height: 24, thickness: 1, color: Color(0xFFE6E6E6)),
                Text('快递单号：${item["express"]}',
                    style: const TextStyle(fontSize: 15, height: 1.8)),
                Text('收货状态：${received ? "已收货" : "未收货"}',
                    style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: received ? Colors.green : Colors.orange)),
                Text('收货人：${item["name"]}',
                    style: const TextStyle(fontSize: 15, height: 1.8)),
                Text('电话：${item["phone"]}',
                    style: const TextStyle(fontSize: 15, height: 1.8)),
                Text('地址：${item["address"]}',
                    style: const TextStyle(fontSize: 15, height: 1.8)),
                const SizedBox(height: 16),

                // ✅ 确认收货按钮（未收货时显示）
                if (!received)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('确认收货'),
                            content: const Text('是否确认已收到礼品？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('取消'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  '确定',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          setState(() {
                            records[index]["received"] = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1677FF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '确认收货',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
