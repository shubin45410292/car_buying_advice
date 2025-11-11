import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/recommend_page.dart';
import 'pages/chat_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const CarBuyingAdviceApp());
}

class CarBuyingAdviceApp extends StatelessWidget {
  const CarBuyingAdviceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '购车咨询系统',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1677FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1677FF),
          primary: const Color(0xFF1677FF),
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const LoginPage(), // 默认从登录页进入
    );
  }
}

///
/// 登录后主界面 —— 底部导航（咨询 / 咨询记录 / 我的 / 我的积分）
///
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RecommendPage(), // 咨询
    ChatPage(),      // 咨询记录（这里你可以换成 history_page.dart）
    ProfilePage(),   // 我的
    PointsPage(),    // 我的积分（可以先建个占位页）
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1677FF),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: '咨询',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: '咨询记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            activeIcon: Icon(Icons.card_giftcard),
            label: '我的积分',
          ),
        ],
      ),
    );
  }
}

///
/// “我的积分”占位页（后续可替换为实际积分页）
///
class PointsPage extends StatelessWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的积分'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          '这里展示积分详情或兑换商城',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
