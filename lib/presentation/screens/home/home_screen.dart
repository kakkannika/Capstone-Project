import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/presentation/screens/home/detail_home_page.dart';
import 'package:tourism_app/presentation/widgets/dertam_searchBar.dart';
import 'package:tourism_app/presentation/widgets/destination_card.dart';
import 'package:tourism_app/presentation/widgets/navigationBar.dart';
import 'package:tourism_app/providers/firebase/place_retrieve_service.dart';
import 'package:tourism_app/providers/firebase/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void onSearchChanged(String text) {}

  void onBackPressed() {}

  @override
  void initState() {
    super.initState();
    // Fetch the data when the screen is initialized
    Provider.of<PlaceProvider>(context, listen: false).fetchAllPlaces();
  }

  @override
  Widget build(BuildContext context) {
    // Access the auth provider
    final authProvider = Provider.of<AuthServiceProvider>(context);
    final currentUser = authProvider.currentUser;

    // Get user's display name or fallback to email or 'User'
    final displayName = currentUser?.displayName ??
        (currentUser?.email.split('@')[0] ?? 'User');

    return Consumer<PlaceProvider>(builder: (context, placeProvider, child) {
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
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: currentUser?.photoUrl != null
                            ? NetworkImage(currentUser!.photoUrl!)
                                as ImageProvider
                            : const AssetImage('lib/assets/images/avatar.jpg'),
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
                      ),
                    ),
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
                    itemCount:
                        6, // Assuming you still want to show a fixed count for the popular destinations
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

                // Grid to display destinations dynamically
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
                  itemCount: placeProvider.places.length,
                  itemBuilder: (context, index) {
                    return DestinationCard(
                      image: placeProvider.places[index].imageURL,
                      title: placeProvider.places[index].name,
                      rating: placeProvider.places[index].averageRating,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              title: placeProvider.places[index].name,
                              imagePath: placeProvider.places[index].imageURL[0],
                              rating: placeProvider.places[index].averageRating,
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
    });
  }
}
