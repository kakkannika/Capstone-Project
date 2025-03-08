import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tourism_app/views/profile/profile_screen.dart';
import 'package:tourism_app/views/home/home_screen.dart';
import 'package:tourism_app/views/trips_screen/trips_plans_screen.dart';

class Navigationbar extends StatelessWidget {
  const Navigationbar({super.key, this.currentIndex = 0});
  
  final int currentIndex;

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
        selectedIndex: currentIndex,
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
        onDestinationSelected: (int index) {
          if (index == currentIndex) return;
          
          switch (index) {
            case 0:
              if (currentIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TripsScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
            // Add case for Budget tab when you implement it
            // case 2:
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => const BudgetScreen()),
            //   );
            //   break;
          }
        },
      ),
    );
  }
}