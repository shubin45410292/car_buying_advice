import 'package:flutter/material.dart';

class RecommendPage extends StatelessWidget {
  const RecommendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('智能推荐')),
      body: const Center(
        child: Text('根据预算、用途、油耗偏好推荐车型'),
      ),
    );
  }
}
