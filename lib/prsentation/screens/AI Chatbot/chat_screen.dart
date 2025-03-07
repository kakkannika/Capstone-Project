import 'package:flutter/material.dart';
import 'dart:async';
import '../AI Chatbot/chat_input_field.dart' as input_field;
import '../../screens/AI Chatbot/header_images.dart';
import '../../screens/AI Chatbot/getting_section.dart';
import '../../screens/AI Chatbot/missage_list.dart';
import '../../widgets/AI_Chatbot/custom_app_bar.dart';
import '../../widgets/AI_Chatbot/custom_drawer.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _hasStartedConversation = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      final now = DateTime.now().toIso8601String();
      setState(() {
        _messages.add({"type": "question", "text": message, "date": now});
        _hasStartedConversation = true;
      });
      _controller.clear();
      _scrollToBottom();
      Future.delayed(const Duration(milliseconds: 500), () {
        _simulateAIResponse("This is a response to: $message");
      });
    }
  }

  void _simulateAIResponse(String response) {
    setState(() {
      _messages.add({"type": "answer", "text": "", "date": DateTime.now().toIso8601String()});
    });

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(messages: _messages, onSelectMessage: _selectMessage),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            HeaderImage(),
            if (!_hasStartedConversation)
              FadeTransition(
                opacity: _fadeAnimation,
                child: GreetingSection(onSuggestionSelected: _sendMessage),
              ),
            Expanded(
              child: MessageList(messages: _messages, scrollController: _scrollController),
            ),
            input_field.ChatInputField(controller: _controller, onSendMessage: _sendMessage),
          ],
        ),
      ),
    );
  }
}