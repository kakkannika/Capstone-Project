// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/presentation/screens/chat_bot/chat_screen.dart';
import 'package:tourism_app/presentation/screens/home/detail_each_place.dart';
import 'package:tourism_app/presentation/screens/home/widget/filter_chip.dart';
import 'package:tourism_app/presentation/widgets/dertam_searchBar.dart';
import 'package:tourism_app/presentation/widgets/destination_card.dart';
import 'package:tourism_app/presentation/widgets/navigationBar.dart';
import 'package:tourism_app/providers/place_provider.dart';
// import 'package:tourism_app/providers/place_retrieve_provider.dart';
import 'package:tourism_app/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'all'; // Stores selected category

  void onSearchChanged(String text) {}

  void onBackPressed() {}

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen is initialized
    Provider.of<PlaceProvider>(context, listen: false).fetchAllPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServiceProvider>(context);
    final currentUser = authProvider.currentUser;
    final displayName = currentUser?.displayName ??
        (currentUser?.email.split('@')[0] ?? 'User');

    return Consumer<PlaceProvider>(builder: (context, placeProvider, child) {
      // Filter places based on selected category
      final filteredPlaces = selectedCategory == 'all'
          ? placeProvider.places
          : placeProvider.places
              .where((place) => place.category == selectedCategory)
              .toList();

      // Fileter popular places
      final popularPlaces = placeProvider.places
          .where((place) => place.averageRating >= 4)
          .take(6)
          .toList();

      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: currentUser?.photoUrl != null
                            ? NetworkImage(currentUser!.photoUrl!)
                            : const AssetImage('lib/assets/images/avatar.jpg')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Hello, $displayName',
                        style: const TextStyle(
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

                // Hero Image & Search Bar
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
                      ),
                    ),
                  ],
                ),

                // Popular Destination Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular Destinations',
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

                // Popular Destination Cards
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: popularPlaces.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailEachPlace(
                                placeId: popularPlaces[index].id),
                          ),
                        ),
                        child: Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image:
                                  NetworkImage(popularPlaces[index].imageURL),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Explore Destination Section
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

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      'all',
                      'museum',
                      'market',
                      'entertain_attraction',
                      'historical_place',
                      'restaurant',
                      'hotel',
                    ]
                        .map((category) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: FiltersChip(
                                label: category,
                                isSelected: selectedCategory == category,
                                onTap: () {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),

                // Destination Grid View
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
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    return DestinationCard(
                      image: filteredPlaces[index].imageURL,
                      title: filteredPlaces[index].name,
                      rating: filteredPlaces[index].averageRating,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailEachPlace(
                                placeId: filteredPlaces[index].id),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const Navigationbar(),
        // Floating Action Button
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 20, right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Shadow color
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(2, 4), // Changes position of shadow
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              print("Chatbot button clicked");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatScreen()));
              // Add navigation or functionality here
            },
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            elevation: 0, // Set to 0 to use the custom shadow
            child: Image.asset(
              'lib/assets/images/chatbot.jpg', // Replace with the actual asset path
              width: 40, // Adjust size as needed
              height: 40,
            ),
          ),
        ),
      );
    });
  }
}
