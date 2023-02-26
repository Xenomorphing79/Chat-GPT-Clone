import 'dart:async';
import 'dart:convert';

// import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/ChatMessage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  bool _isImageSearch = false;
  bool _isTyping = false;

  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
      token: dotenv.env["API_KEY"],
      baseOption: HttpSetup(receiveTimeout: 60000),
    );
    super.initState();
  }

  @override
  void dispose() {
    chatGPT!.genImgClose();
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    final String text = _controller.text;
    final ChatMessage message = ChatMessage(
      text: text,
      sender: "You",
      isImageSearch: false,
    );
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });
    _controller.clear();

    if (_isImageSearch) {
      final request = GenerateImage(message.text, 1);
      _subscription = chatGPT!
          .generateImageStream(request)
          .asBroadcastStream()
          .listen((response) {
        Vx.log(response.data!.last!.url!);
        insertNewData(response.data!.last!.url!, isImageSearch: true);
      });
    } else {
      final request = CompleteText(
        prompt: message.text,
        model: kTranslateModelV3,
        n: 1,
        maxTokens: 200,
      );

      _subscription = chatGPT!
          .onCompleteStream(request: request)
          .asBroadcastStream()
          .listen((response) {
        insertNewData(response!.choices[0].text, isImageSearch: false);
      });
    }
  }

  void insertNewData(String response, {bool isImageSearch = false}) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImageSearch: isImageSearch,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
              controller: _controller,
              onSubmitted: (value) => _sendMessage(),
              decoration: const InputDecoration.collapsed(
                  hintText: "Enter something...")),
        ),
        ButtonBar(
          children: [
            IconButton(
                onPressed: () {
                  _isImageSearch = false;
                  _sendMessage();
                },
                icon: const Icon(Icons.send)),
            TextButton(
                onPressed: () {
                  _isImageSearch = true;
                  _sendMessage();
                },
                child: const Text("Generate Image")),
          ],
        )
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
