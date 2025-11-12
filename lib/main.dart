import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 页面引入
import 'pages/login_page.dart';
import 'pages/recommend_page.dart';
import 'pages/consultation_records_page.dart';
import 'pages/profile_page.dart';
import 'pages/points_page.dart';

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
      home: const LaunchPage(), // ✅ 启动时自动判断登录状态
    );
  }
}

///
/// 启动页：判断是否登录（通过 token 判断）
///
class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  bool _checking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ 根据 token 决定跳转页面
    return _isLoggedIn ? const MainLayout() : const LoginPage();
  }
}

///
/// 登录后主界面 —— 底部导航栏结构
///
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  /// 从其他页面切换 tab（例如“我的积分”跳转）
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

  void _switchTo(int index) {
    if (!mounted) return;
    setState(() => _currentIndex = index);
  }

  final List<Widget> _pages = const [
    RecommendPage(),            // 0: 车型推荐 / 咨询
    ConsultationRecordsPage(),  // 1: 咨询记录
    ProfilePage(),              // 2: 我的
    PointsRecordPage(),               // 3: 积分中心
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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