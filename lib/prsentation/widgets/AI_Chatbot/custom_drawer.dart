import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/utils/date_time_util.dart'; // Import the utility class

class CustomDrawer extends StatelessWidget {
  final List<Map<String, String>> messages;
  final Function(Map<String, String>) onSelectMessage;

  CustomDrawer({required this.messages, required this.onSelectMessage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            accountName: Text(
              'Virakbott',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            accountEmail: Text(
              'virakbott@example.com',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('lib/assets/trip_plan_images/user.jpg'),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('History (${messages.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          ...messages.map((message) {
            final date = DateTime.parse(message['date']!);
            return Column(
              children: [
                ListTile(
                  title: Text(message['text']!),
                  subtitle: Text('${message['type'] == 'question' ? 'User' : 'AI'} - ${DateTimeUtils.formatDateTime(date)}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(message['type'] == 'question' ? "User's Question" : "AI's Response"),
                        content: Text(message['text']!),
                        actions: [
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}