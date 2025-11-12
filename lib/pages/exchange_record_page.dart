//展示兑换记录，并可点“确认收货”改状态。
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
  bool received = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('兑换记录'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('usb充电器', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('快递单号：2187666798980'),
              const SizedBox(height: 4),
              Text('收货状态：${received ? "已收货" : "未收货"}'),
              const SizedBox(height: 4),
              Text('收货人：${widget.name}'),
              Text('电话：${widget.phone}'),
              Text('地址：${widget.address}'),
              const SizedBox(height: 16),
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
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        setState(() => received = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('确认收货'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
