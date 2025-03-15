import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/chat_bot/chat_input_field.dart';
import 'package:tourism_app/presentation/screens/chat_bot/message_list.dart';
import 'package:tourism_app/presentation/screens/chat_bot/widget/custom_chatbot_bar.dart';
import 'package:tourism_app/presentation/screens/chat_bot/widget/custom_chatbot_drawer.dart';
import 'package:tourism_app/providers/chatbot_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _hasStartedConversation = false;

  // Initialize chatbot service
  final CustomChatbotService _chatbotService = CustomChatbotService(
    apiUrl:
        'https://3b92-36-37-169-49.ngrok-free.app/chat', // Replace with your actual endpoint
  );

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      final now = DateTime.now().toIso8601String();
      setState(() {
        _messages.add({"type": "question", "text": message, "date": now});
        _hasStartedConversation = true;
      });
      _controller.clear();
      _scrollToBottom();

      // Call chatbot service to get a response
      _getChatbotResponse(message);
    }
  }

  Future<void> _getChatbotResponse(String message) async {
    setState(() {
      _messages.add({
        "type": "answer",
        "text": "", // Empty initially
        "date": DateTime.now().toIso8601String()
      });
    });

    try {
      String response = await _chatbotService.sendMessageWithRetry(message);
      _animateAIResponse(response);
    } catch (e) {
      _animateAIResponse("Error fetching response. Please try again.");
    }
  }

  void _animateAIResponse(String response) {
    String completeResponse = response;
    int charIndex = 0;

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (charIndex < completeResponse.length) {
        setState(() {
          _messages.last["text"] = completeResponse.substring(0, charIndex + 1);
        });
        charIndex++;
      } else {
        timer.cancel();
      }
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _selectMessage(Map<String, String> message) {
    Navigator.of(context).pop();
    setState(() {
      _messages.add(message);
      _hasStartedConversation = true;
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer:
          CustomDrawer(messages: _messages, onSelectMessage: _selectMessage),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Modern greeting section, styled with background
            if (!_hasStartedConversation)
              GestureDetector(
                onTap: () => _sendMessage("Hello!"),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6)
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Text(
                    "Start Chatting with our AI Assistant!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: MessageList(
                messages: _messages,
                scrollController: _scrollController,
              ),
            ),
            // Custom Input Field
            ChatInputField(
                controller: _controller, onSendMessage: _sendMessage),
          ],
        ),
      ),
    );
  }
}
