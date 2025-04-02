import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/utils/date_time_util.dart'; // Import the utility class

class CustomDrawer extends StatelessWidget {
  final List<Map<String, String>> messages;
  final Function(Map<String, String>) onSelectMessage;

  const CustomDrawer(
      {super.key, required this.messages, required this.onSelectMessage});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServiceProvider>(context);
    final currentUser = authProvider.currentUser;
    final displayName = currentUser?.displayName ??
        (currentUser?.email.split('@')[0] ?? 'User');
    final userEmail = currentUser?.email ?? 'No email';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
             decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DertamColors.primary,
                  DertamColors.lightBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              displayName,
              style: DertamTextStyles.title.copyWith(
                color: DertamColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              userEmail,
              style: DertamTextStyles.body.copyWith(
                color: DertamColors.white,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: currentUser?.photoUrl != null
                  ? NetworkImage(currentUser!.photoUrl!)
                  : const AssetImage('assets/images/avatar.jpg')
                      as ImageProvider,
            ),
          ),
          Divider(color: DertamColors.greyLight),
          Padding(
            padding: EdgeInsets.all(DertamSpacings.m),
            child: Text(
              'History (${messages.length})',
              style: DertamTextStyles.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(color:  DertamColors.greyLight,),
          ...messages.map((message) {
            final date = DateTime.parse(message['date']!);
            return Column(
              children: [
                ListTile(
                  title: Text(
                    message['text']!,
                    style: DertamTextStyles.body,
                    ),
                  subtitle: Text(
                      '${message['type'] == 'question' ? 'User' : 'AI'} - ${DateTimeUtils.formatDateTime(date)}',
                      style: DertamTextStyles.label.copyWith(
                      color: DertamColors.neutralLight,
                    ),
                    ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(message['type'] == 'question'
                            ? "User's Question"
                            : "AI's Response",
                            style: DertamTextStyles.title,
                            ),
                        content: Text(
                          message['text']!, 
                          style: DertamTextStyles.body,),
                        actions: [
                          TextButton(
                            child: Text(
                              "Close",
                            style: DertamTextStyles.button.copyWith(
                                color: DertamColors.primary,
                              ),
                              ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(color: DertamColors.greyLight),
              ],
            );
          }),
        ],
      ),
    );
  }
}
