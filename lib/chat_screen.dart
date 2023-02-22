import 'dart:async';
import 'dart:convert';

// import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/ChatMessage.dart';
import 'package:velocity_x/velocity_x.dart';
// import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

import 'ThreeDots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  OpenAI? chatGPT;
  StreamSubscription? _subscription;

  bool _isTyping = false;

  @override
  void initState() {
    chatGPT = OpenAI.instance;
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _controller.text;
    final ChatMessage message = ChatMessage(
      text: text,
      sender: "You",
    );
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });
    _controller.clear();

    final request = CompleteText(
      prompt: message.text,
      model: kTranslateModelV3,
      n: 1,
      maxTokens: 200,
    );

    _subscription = chatGPT!
        .build(
          token: "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",
        )
        .onCompleteStream(request: request)
        .listen((response) {
      ChatMessage botMessage =
          ChatMessage(text: response!.choices[0].text, sender: "Bot");
      setState(() {
        _isTyping = false;
        _messages.insert(0, botMessage);
      });
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
              controller: _controller,
              onSubmitted: (value) => _sendMessage(),
              decoration:
                  const InputDecoration.collapsed(hintText: "Send a message")),
        ),
        IconButton(
            onPressed: () => _sendMessage(), icon: const Icon(Icons.send))
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
            if (_isTyping) const ThreeDots(),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 1,
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
