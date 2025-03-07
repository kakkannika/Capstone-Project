import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final List<Map<String, String>> messages;
  final ScrollController scrollController;

  MessageList({required this.messages, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isQuestion = message["type"] == "question";
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: isQuestion ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isQuestion) ...[
                const CircleAvatar(
                  backgroundImage: AssetImage('lib/assets/trip_plan_images/ai.png'),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isQuestion ? Colors.blue[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message["text"]!,
                    style: TextStyle(
                      color: isQuestion ? Colors.blue : Colors.black,
                      fontWeight: isQuestion ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (isQuestion) ...[
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundImage: AssetImage('lib/assets/trip_plan_images/user.jpg'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}