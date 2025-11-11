import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 购车咨询')),
      body: const Center(
        child: Text('这里做对话界面，后面接你们的 LLM / 后端接口'),
      ),
    );
  }
}
