import 'package:flutter/material.dart';


class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 静态模拟数据（后端返回的结构）
    final data = {
      "Analysis":
          "根据您的预算、偏好车型、使用场景以及对电动车辆的倾向，我们为您推荐了适合日常通勤且能满足周末休闲出行需求的SUV车型。",
      "Proposal":
          "基于您的需求，建议考虑以下两款车型。它们在性能、舒适性和经济性方面均表现优秀，适合城市通勤与家庭出行。",
      "Result": [
        {
          "ImageUrl": "https://img1.baidu.com/it/u=1626822570,2893215833&fm=253",
          "CarName": "比亚迪宋PLUS EV",
          "Power": "135kW / 184马力",
          "Seat": "5座",
          "Drive": "前驱",
          "FuelConsumption": "纯电动",
          "RecommendedReason":
              "比亚迪宋PLUS EV续航长、空间宽敞，适合家庭使用。性价比高，充电便利。"
        },
        {
          "ImageUrl":
              "https://img0.baidu.com/it/u=2037645185,3408279650&fm=253",
          "CarName": "吉利帝豪X EV",
          "Power": "120kW / 163马力",
          "Seat": "5座",
          "Drive": "前驱",
          "FuelConsumption": "纯电动",
          "RecommendedReason":
              "帝豪X EV外观时尚，驾驶平顺，适合追求经济实用的城市用户。"
        }
      ]
    };

    final cars = List<Map<String, dynamic>>.from(data['Result'] as List);


    return Scaffold(
      appBar: AppBar(title: const Text('购车咨询结果')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('分析与总结'),
            Text(
              data['Analysis']as String,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            _sectionTitle('推荐车型'),
            ...cars.map(_buildCarCard).toList(),
            const SizedBox(height: 20),
            _sectionTitle('购车建议'),
            Text(
              data['Proposal']as String,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                car['ImageUrl']!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              car['CarName']!,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('动力：${car['Power']}'),
            Text('驱动：${car['Drive']}'),
            Text('座位：${car['Seat']}'),
            Text('能耗：${car['FuelConsumption']}'),
            const SizedBox(height: 8),
            Text(
              car['RecommendedReason']!,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
