import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage(
      {super.key,
      required this.text,
      required this.sender,
      this.isImageSearch = false});

  final String text;
  final String sender;
  final bool isImageSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sender)
            .text
            .subtitle1(context)
            .make()
            .box
            .color(sender == 'user' ? Vx.blue100 : Vx.green100)
            .alignCenter
            .rounded
            .p8
            .margin(const EdgeInsets.only(right: 20))
            .makeCentered(),
        Expanded(
          child: isImageSearch
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    text,
                    loadingBuilder: (context, child, loadingProgress) =>
                        loadingProgress == null
                            ? child
                            : const CircularProgressIndicator.adaptive(),
                  ))
              : text.trim().text.bodyText1(context).make().px16(),
        ),
      ],
    ).py12();
  }
}
