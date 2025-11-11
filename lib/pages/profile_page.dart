import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  int points = 0;
  int consultCount = 0;
  int favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '未登录';
      points = prefs.getInt('points') ?? 0;
      consultCount = prefs.getInt('consultCount') ?? 0;
      favoriteCount = prefs.getInt('favoriteCount') ?? 0;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            color: const Color(0xFF1677FF),
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text('U', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(height: 8),
                Text(username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoItem('咨询次数', consultCount.toString()),
                    _infoItem('我的积分', points.toString()),
                    _infoItem('收藏车型', favoriteCount.toString()),
                  ],
                ),
              ],
            ),
          ),
          const ListTile(title: Text('我的服务')),
          const Divider(height: 0),
          const ListTile(title: Text('咨询记录')),
          const ListTile(title: Text('我的积分')),
          const ListTile(title: Text('收藏车型')),
          const Divider(height: 8, color: Colors.transparent),
          const ListTile(title: Text('系统设置')),
          const ListTile(title: Text('个人信息')),
          const ListTile(title: Text('偏好设置')),
          const ListTile(title: Text('帮助中心')),
          const ListTile(title: Text('隐私政策')),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('退出登录'),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
