import 'package:flutter/material.dart';

class PointsPage extends StatelessWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rewards = [
      {
        "image":
            "https://img2.baidu.com/it/u=2092109498,2099515091&fm=253&fmt=auto",
        "title": "车载无线充电支架",
        "desc": "自动夹紧设计，支持15W快充",
        "points": 800
      },
      {
        "image":
            "https://img0.baidu.com/it/u=3783092675,2207017494&fm=253&fmt=auto",
        "title": "智能行车记录仪",
        "desc": "高清夜视，支持语音控制",
        "points": 1500
      },
      {
        "image":
            "https://img1.baidu.com/it/u=2345634090,1287705700&fm=253&fmt=auto",
        "title": "车载香薰套装",
        "desc": "持久清香，除味提神",
        "points": 300
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('积分兑换中心')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rewards.length,
        itemBuilder: (context, i) {
          final item = rewards[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image']as String,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']as String,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(item['desc']as String,
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item['points']} 积分',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
