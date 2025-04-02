import 'package:flutter/material.dart';
import 'package:tourism_app/theme/theme.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;

  const ChatInputField(
      {super.key, required this.controller, required this.onSendMessage});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  // ignore: unused_field
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _isTyping = widget.controller.text.isNotEmpty;
      });
    });
  }

  void _sendMessage() {
    final message = widget.controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: DertamColors.backgroundAccent,
                  borderRadius: BorderRadius.circular(DertamSpacings.radiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: widget.controller,
                    style: DertamTextStyles.body.copyWith(
                      color: DertamColors.neutralDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _sendMessage();
              },
              icon: Icon(
                Icons.send,
                color: DertamColors.primary,
                size: DertamSize.icon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
