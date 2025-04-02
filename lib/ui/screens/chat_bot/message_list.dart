import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';

class MessageList extends StatelessWidget {
  final List<Map<String, String>> messages;
  final ScrollController scrollController;

  const MessageList(
      {super.key, required this.messages, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServiceProvider>(context);
    final currentUser = authProvider.currentUser;
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isQuestion = message["type"] == "question";
        return Padding(
          padding: EdgeInsets.symmetric(vertical: DertamSpacings.s / 3),
          child: Row(
            mainAxisAlignment:
                isQuestion ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isQuestion) ...[
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/chatbot.jpg'),
                ),
                SizedBox(width: DertamSpacings.s),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(DertamSpacings.s),
                  decoration: BoxDecoration(
                    color: isQuestion 
                    ? DertamColors.blueSky 
                    : DertamColors.backgroundAccent,
                    borderRadius: BorderRadius.circular(DertamSpacings.radius),
                    boxShadow: [
                      BoxShadow(
                        color: DertamColors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message["text"]!,
                    style: DertamTextStyles.body.copyWith(
                      color: isQuestion 
                          ? DertamColors.primary 
                          : DertamColors.neutralDark,
                      fontWeight: isQuestion 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (isQuestion) ...[
                const SizedBox(width:  DertamSpacings.s),
                CircleAvatar(
                  backgroundImage: currentUser?.photoUrl != null
                      ? NetworkImage(currentUser!.photoUrl!)
                      : const AssetImage('assets/images/avatar.jpg')
                          as ImageProvider,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
