import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/widgets/tam_searchbar.dart';
import 'package:tourism_app/prsentation/widgets/destination_card.dart';
import 'package:tourism_app/prsentation/widgets/navigationbar.dart';
import 'package:tourism_app/prsentation/screens/home/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void onSearchChanged(String text) {}

  void onBackPressed() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile and icons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          AssetImage('lib/assets/images/avatar.jpg'),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Hello, Kannika',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.language),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Hero image and search bar
              Stack(
                children: [
                  Image.asset(
                    'lib/assets/place_images/Angkor_wat.jpg',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: TamSearchbar(
                        onBackPressed: onBackPressed,
                        onSearchChanged: onSearchChanged,
                      )),
                ],
              ),

              // Popular destination section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular destination',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),

              // Popular destination cards
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(
                              'lib/assets/place_images/popular_${index + 1}.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Explore Destination section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Explore Destination',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Weekend Trips section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Weekend Trips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Weekend trips grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return DestinationCard(
                    image:
                        'lib/assets/place_images/destination_${index + 1}.jpg',
                    title: _getDestinationTitle(index),
                    rating: 4.0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: _getDestinationTitle(index),
                            imagePath:
                                'lib/assets/place_images/destination_${index + 1}.jpg',
                            rating: 4.0,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 80), // Bottom padding for navigation bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Navigationbar(),
    );
  }

  String _getDestinationTitle(int index) {
    switch (index) {
      case 0:
        return 'Takeo Province';
      case 1:
        return 'SiemReap Province';
      case 2:
        return 'Phnom Penh';
      case 3:
        return 'Preah Vihear';
      default:
        return '';
    }
  }
}
