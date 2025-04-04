import 'package:flutter/material.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/screens/home/home_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [DertamColors.primary, DertamColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
      ),
      title: Text(
        "Dertam Chatbot",
        style: TextStyle(
            color: DertamColors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
