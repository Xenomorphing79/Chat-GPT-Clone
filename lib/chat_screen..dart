import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/ChatMessage.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
              controller: _controller,
              decoration:
                  const InputDecoration.collapsed(hintText: "Send a message")),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.send))
      ],
    ).px12();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Chat GPT",
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: _messages.length,
                reverse: true,
                padding: Vx.m8,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(color: context.cardColor),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}
