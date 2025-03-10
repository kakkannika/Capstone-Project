// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/repositories/firebase/place_retrieve_service.dart';
import 'package:tourism_app/models/place/place.dart';

class DetailEachPlace extends StatefulWidget {
  final String placeId;

  const DetailEachPlace({
    super.key,
    required this.placeId,
  });

  @override
  State<DetailEachPlace> createState() => _DetailEachPlaceState();
}

class _DetailEachPlaceState extends State<DetailEachPlace> {
  Place? place;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaceData();
  }

  Future<void> _loadPlaceData() async {
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    try {
      final fetchedPlace = await placeProvider.getPlaceById(widget.placeId);
      setState(() {
        place = fetchedPlace;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading place: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : place == null
              ? const Center(child: Text('Place not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Stack with Image and Back Button
                      Stack(
                        children: [
                          place!.imageURL.isNotEmpty
                              ? Image.network(
                                  place!.imageURL,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/placeholder.jpg',
                                      width: double.infinity,
                                      height: 250,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/placeholder.jpg',
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                          Positioned(
                            top: 40,
                            left: 20,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                child: const Icon(Icons.arrow_back),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Use place.location for navigation
                                // You can open Google Maps or your own map implementation
                              },
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Route'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Title and Rating Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Location section
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.red, size: 20),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          // Format GeoPoint to display latitude and longitude
                                          '${place!.location.latitude}, ${place!.location.longitude}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Rating section
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star,
                                        color: index < place!.averageRating.floor()
                                            ? Colors.amber
                                            : Colors.grey[300],
                                        size: 18, // Reduced from 20 to 18
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      place!.averageRating.toString(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          place!.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Start Planning Button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Start Planning',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Information Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // You can add more place-specific information here
                            Row(
                              children: [
                                const Icon(Icons.access_time),
                                const SizedBox(width: 8),
                                Text(
                                  'Opening Hours: ${place!.openingHours}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    // Open Google Maps with place coordinates
                                  },
                                  child: const Text('View on Google Maps'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Nearby sections would be implemented similarly
                      _buildSectionTitle('Experiences nearby'),
                      // You would fetch nearby experiences from Firestore here
                      SizedBox(
                        height: 150,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildExperienceCard('Silver Pagoda', 5),
                            _buildExperienceCard('Norodom Sihanouk Museum', 5),
                            _buildExperienceCard('Norodom Sihanouk Museum', 5),
                          ],
                        ),
                      ),

                      // Hotels section
                      _buildSectionTitle('Hotel Nearby'),
                      // You would fetch nearby hotels from Firestore here
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildHotelCard(
                              'Palace Gate Hotel',
                              5.0,
                              'Jungle in the city centre',
                            ),
                            const SizedBox(height: 16),
                            _buildHotelCard(
                              'The Peninsula Phnom Penh',
                              5.0,
                              'Luxury hotel',
                            ),
                          ],
                        ),
                      ),

                      // Restaurants section
                      _buildSectionTitle('Restaurant Nearby'),
                      // You would fetch nearby restaurants from Firestore here
                      SizedBox(
                        height: 150,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildRestaurantCard('Chez Tonton', 'Pop Street', 5.0),
                            _buildRestaurantCard('Chez Tonton', 'Pop Street', 5.0),
                            _buildRestaurantCard('Chez Tonton', 'Pop Street', 5.0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExperienceCard(String title, double rating) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/images/placeholder.jpg',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' $rating'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(String name, double rating, String description) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/images/placeholder.jpg',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' $rating'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(String name, String location, double rating) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/images/placeholder.jpg',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' $rating'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}