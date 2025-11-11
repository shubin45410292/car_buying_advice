import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('购车咨询首页')),
      body: const Center(
        child: Text('这里放轮播图、热门车型、基础介绍'),
      ),
    );
  }
}
