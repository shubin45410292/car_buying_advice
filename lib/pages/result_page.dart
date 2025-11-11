import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic>? apiResponseData;

  const ResultPage({
    super.key,
    this.apiResponseData,
  });

  @override
  Widget build(BuildContext context) {
    // 使用传入的API数据，如果没有则使用静态数据
    final data = apiResponseData != null 
        ? _formatApiResponse(apiResponseData!)
        : {
            "Analysis": "根据您的预算、偏好车型、使用场景以及对电动车辆的倾向，我们为您推荐了适合日常通勤且能满足周末休闲出行需求的SUV车型。",
            "Proposal": "基于您的需求，建议考虑以下两款车型。它们在性能、舒适性和经济性方面均表现优秀，适合城市通勤与家庭出行。",
            "Result": [
              {
                "ImageUrl": "https://img1.baidu.com/it/u=1626822570,2893215833&fm=253",
                "CarName": "比亚迪宋PLUS EV",
                "Power": "135kW / 184马力",
                "Seat": "5座",
                "Drive": "前驱",
                "FuelConsumption": "纯电动",
                "RecommendedReason": "比亚迪宋PLUS EV续航长、空间宽敞，适合家庭使用。性价比高，充电便利。"
              },
              {
                "ImageUrl": "https://img0.baidu.com/it/u=2037645185,3408279650&fm=253",
                "CarName": "吉利帝豪X EV",
                "Power": "120kW / 163马力",
                "Seat": "5座",
                "Drive": "前驱",
                "FuelConsumption": "纯电动",
                "RecommendedReason": "帝豪X EV外观时尚，驾驶平顺，适合追求经济实用的城市用户。"
              }
            ]
          };

    final cars = List<Map<String, dynamic>>.from(data['Result'] as List);

    return Scaffold(
      appBar: AppBar(
        title: const Text('购车咨询结果'),
        backgroundColor: Color(0xFF1677FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('分析与总结'),
            Text(
              data['Analysis'] as String,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),
            _sectionTitle('推荐车型'),
            ...cars.map(_buildCarCard).toList(),
            const SizedBox(height: 20),
            _sectionTitle('购车建议'),
            Text(
              data['Proposal'] as String,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // 格式化API响应数据
  Map<String, dynamic> _formatApiResponse(Map<String, dynamic> apiResponse) {
    final data = apiResponse['data'];
    return {
      "Analysis": data['Analysis'] as String? ?? "",
      "Proposal": data['Proposal'] as String? ?? "",
      "Result": (data['Result'] as List?)?.map((car) {
        return {
          "ImageUrl": car['ImageUrl'] as String? ?? "",
          "CarName": car['CarName'] as String? ?? "",
          "Power": car['Power'] as String? ?? "",
          "Seat": car['Seat'] as String? ?? "",
          "Drive": car['Drive'] as String? ?? "",
          "FuelConsumption": car['FuelConsumption'] as String? ?? "",
          "RecommendedReason": car['RecommendedReason'] as String? ?? "",
        };
      }).toList() ?? [],
    };
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1677FF),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Icon(Icons.car_rental, size: 50, color: Colors.grey[400]),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              car['CarName']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1677FF),
              ),
            ),
            const SizedBox(height: 8),
            _buildCarSpec('⚡ 动力', car['Power']!),
            _buildCarSpec('🚗 驱动', car['Drive']!),
            _buildCarSpec('💺 座位', car['Seat']!),
            _buildCarSpec('⛽ 能耗', car['FuelConsumption']!),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                car['RecommendedReason']!,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarSpec(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
