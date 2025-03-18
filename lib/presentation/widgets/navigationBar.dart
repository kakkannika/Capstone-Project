// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tourism_app/presentation/screens/profiles/profile_screen.dart';

class Navigationbar extends StatelessWidget {
  const Navigationbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: NavigationBar(
        height: 70,
        elevation: 0,
        selectedIndex: 0,
        backgroundColor: Colors.white,
        onDestinationSelected: (index) {
          if (index == 3) {
            // Profile tab index
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
          NavigationDestination(icon: Icon(Iconsax.folder), label: 'Trip Plan'),
          NavigationDestination(icon: Icon(Iconsax.heart), label: 'Favorite'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
    );
  }
}
