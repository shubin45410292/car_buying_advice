import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'exchange_record_page.dart';

class ExchangeInfoPage extends StatefulWidget {
  const ExchangeInfoPage({super.key});

  @override
  State<ExchangeInfoPage> createState() => _ExchangeInfoPageState();
}

class _ExchangeInfoPageState extends State<ExchangeInfoPage> {
  bool isLoading = false;
  List<Map<String, dynamic>> giftList = [];

  @override
  void initState() {
    super.initState();
    _fetchGifts();
  }

  // ==============================
  // 🔹 获取礼品列表
  // ==============================
  Future<void> _fetchGifts() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get("/api/score/gift/query");
      final base = response['base'];
      final data = response['data'];

      if (base != null && base['code'] == 10000 && data != null) {
        final items = List<Map<String, dynamic>>.from(data['item'] ?? []);
        setState(() => giftList = items);
      } else {
        _showError(base?['msg'] ?? '获取礼品失败');
      }
    } catch (e) {
      _showError('请求出错: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ==============================
  // 🎁 兑换礼品
  // ==============================
  Future<void> _exchangeGift(int giftId, String giftName) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/api/score/gift/purchase')
          .replace(queryParameters: {'gift_id': giftId.toString()});

      final response = await ApiService.authPost(uri);

      debugPrint("🎯 兑换接口: $uri");
      debugPrint("📦 状态码: ${response.statusCode}");
      debugPrint("📄 响应体: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final base = result['base'];

        if (base != null && base['code'] == 10000) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('兑换成功：$giftName')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ExchangeRecordPage(
                name: '',
                phone: '',
                address: '',
              ),
            ),
          );
        } else {
          _showError(base?['msg'] ?? '兑换失败');
        }
      } else {
        _showError('服务器错误：${response.statusCode}');
      }
    } catch (e) {
      _showError('网络异常：$e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // ==============================
  // 🧱 构建页面
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('兑换汽车周边'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.location_on_outlined, color: Colors.black54),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : giftList.isEmpty
          ? const Center(child: Text('暂无可兑换礼品'))
          : GridView.builder(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: giftList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final gift = giftList[index];
          return _buildGiftCard(gift);
        },
      ),
    );
  }

  // ==============================
  // 🎨 礼品卡片
  // ==============================
  Widget _buildGiftCard(Map<String, dynamic> gift) {
    final giftId = gift['gift_id'] ?? 0;
    final name = gift['gift_name'] ?? '未知礼品';
    final imgUrl = gift['cover_image_url'] ?? '';
    final points = gift['required_points']?.toString() ?? '0';
    final stock = gift['stock_quantity']?.toString() ?? '-';

    return InkWell(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('确认兑换'),
            content: Text('是否使用 $points 积分兑换 "$name"？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1677FF),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确定', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm == true) _exchangeGift(giftId, name);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: imgUrl.isNotEmpty
                    ? Image.network(imgUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.image_not_supported)))
                    : const Center(
                  child: Icon(Icons.image_outlined,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "库存：$stock",
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1677FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$points 积分",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
