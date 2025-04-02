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
            colors: [
              DertamColors.primary,
              DertamColors.lightBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            color: DertamColors.white,
            size: DertamSize.icon,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Row(
        children: [
          Text("AI Chat",
          style: DertamTextStyles.title.copyWith(
              color: DertamColors.white,
              fontWeight: FontWeight.bold,
          )),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.home,
            color: DertamColors.white,
            size: DertamSize.icon,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}