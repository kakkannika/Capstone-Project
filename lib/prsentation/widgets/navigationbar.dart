import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.folder),
            label: 'Trip Plan',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.money),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.user),
            label: 'Profile',
          )
        ],
      ),
    );
  }
}
