import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/recommend_page.dart';
import 'pages/chat_page.dart';
import 'pages/profile_page.dart';
import 'pages/points_page.dart';
import 'pages/points_record_page.dart';

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
      home: const LoginPage(), // 登录后再跳转 MainLayout
    );
  }
}

///
/// 登录后主界面 —— 底部导航栏结构
///
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  /// ✅ 静态切换方法，用于从其他页面（如 ProfilePage）切换 Tab
  static void switchTab(int index) {
    final state = _MainLayoutState.instance;
    if (state != null && state.mounted) {
      state._switchTo(index);
    }
  }

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  static _MainLayoutState? instance;
  int _currentIndex = 0;

  _MainLayoutState() {
    instance = this;
  }

  /// ✅ 内部安全切换方法（修复 protected 成员警告）
  void _switchTo(int index) {
    if (!mounted) return;
    setState(() => _currentIndex = index);
  }

  final List<Widget> _pages = const [
    RecommendPage(), // 0: 车型推荐 / 咨询
    ChatPage(),      // 1: 咨询记录
    ProfilePage(),   // 2: 我的
    PointsRecordPage(),    // 3: 积分中心
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ IndexedStack 保留各页状态
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // ✅ 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1677FF),
        unselectedItemColor: Colors.grey,
        onTap: (index) => _switchTo(index),
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
            label: '积分中心',
          ),
        ],
      ),
    );
  }
}
