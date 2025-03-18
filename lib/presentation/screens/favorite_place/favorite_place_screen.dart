import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../home/detail_each_place.dart';

class FavoritePlaceScreen extends StatelessWidget {
  const FavoritePlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Favorite Places'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return const FavoritePlaceItem();
        },
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        destinations: [
          NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
          NavigationDestination(icon: Icon(Iconsax.folder), label: 'Trip Plan'),
          NavigationDestination(icon: Icon(Iconsax.heart), label: 'Favorite'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
    );
  }
}

class FavoritePlaceItem extends StatelessWidget {
  const FavoritePlaceItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        title: Text('Favorite Place'),
        subtitle: Text('This is a favorite place'),
        leading: Image.network(
          'https://s1-piq.codeus.net/2019/07/19/TirigCkuBtQfnrUkGGNBju3q_400x400.png',
          width: 50,
          height: 50,
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.heart_broken),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DetailEachPlace(
                      name: '',
                      location: '',
                      rating: 4.5,
                      description: '',
                      imagePath: '',
                    )),
          );
        },
      ),
    );
  }
}
