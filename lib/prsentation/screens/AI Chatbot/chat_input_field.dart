import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;

  ChatInputField({required this.controller, required this.onSendMessage});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: "Ask any travel-related questions",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: _isTyping ? Colors.lightBlue[100] : Colors.grey[100],
          suffixIcon: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.2),
              ),
              child: const Icon(Icons.arrow_upward, color: Colors.blue),
            ),
            onPressed: _sendMessage,
          ),
        ),
      ),
    );
  }
}