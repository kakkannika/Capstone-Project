import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/providers/place_provider.dart';
import 'package:tourism_app/views/widgets/navigationbar.dart';
import 'package:tourism_app/views/trips_screen/start_planning.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlaceProvider>(context, listen: false).fetchHomeScreenData();
    });
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: () {},
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinations(List<dynamic> places) {
    // Sort places by rating in descending order
    final sortedPlaces = List.from(places)
      ..sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sortedPlaces.length,
        itemBuilder: (context, index) {
          final place = sortedPlaces[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(place.imageUrls[0]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreDestinations(List<dynamic> places) {
    // Shuffle places for random order
    final shuffledPlaces = List.from(places)..shuffle();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: shuffledPlaces.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final place = shuffledPlaces[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                place.imageUrls[0],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              place.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildWeekendTrips(List<dynamic> places) {
    // Shuffle places for random order
    final shuffledPlaces = List.from(places)..shuffle();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: shuffledPlaces.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final place = shuffledPlaces[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(place.imageUrls[0]),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final placeProvider = Provider.of<PlaceProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: placeProvider.isLoading
            ? _buildLoadingWidget()
            : RefreshIndicator(
                onRefresh: () => placeProvider.fetchHomeScreenData(),
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
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
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

                      // Hero image
                      Image.network(
                        'https://angkortempleguide.com/wp-content/uploads/2020/10/Angkor-wat-temple-in-siem-reap-cambodia-1.jpg',
                        width: double.infinity,
                        height: 200, // Reduced height since we removed the search bar
                        fit: BoxFit.cover,
                      ),

                      // Popular destinations
                      _buildSectionTitle('Popular destination'),
                      if (placeProvider.popularPlaces.isNotEmpty)
                        _buildPopularDestinations(placeProvider.popularPlaces),

                      // Explore destinations
                      _buildSectionTitle('Explore Destination'),
                      if (placeProvider.explorePlaces.isNotEmpty)
                        _buildExploreDestinations(placeProvider.explorePlaces),

                      // Weekend trips
                      _buildSectionTitle('Weekend Trips'),
                      if (placeProvider.weekendTripPlaces.isNotEmpty)
                        _buildWeekendTrips(placeProvider.weekendTripPlaces),

                      const SizedBox(height: 80), // Bottom padding for navigation bar
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlanNewTripScreen()),
          );
        },
        backgroundColor: const Color(0xFF0D3E4C),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const Navigationbar(),
    );
  }
}