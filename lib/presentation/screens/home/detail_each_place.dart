import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/presentation/googlemap/map_screen.dart';
import 'package:tourism_app/repository/firebase/place_firebase_repository.dart';
import 'package:tourism_app/presentation/screens/trip/screen/start_plan_screen.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';
import 'package:tourism_app/providers/place_provider.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Add these variables for nearby places
  List<Place> nearbyPlaces = [];
  List<Place> nearbyHotels = [];
  List<Place> nearbyRestaurants = [];
  bool loadingNearby = false;

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

      // Load nearby places after main place loads
      if (place != null) {
        _loadNearbyPlaces();
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading place: $error')),
      );
    }
  }

  Future<void> _loadNearbyPlaces() async {
    if (place == null) return;

    setState(() {
      loadingNearby = true;
    });

    try {
      final placeProvider = Provider.of<PlaceProvider>(context, listen: false);

      // Find all places within 5km
      final allNearbyPlaces = await placeProvider.findPlacesNearLocation(
          place!.location, 5.0 // 5 km radius
          );

      // Filter by category
      final attractions = allNearbyPlaces
          .where((p) =>
              p.id != widget.placeId && // Exclude current place
              p.category.toLowerCase() == 'attraction')
          .toList();

      final hotels = allNearbyPlaces
          .where((p) =>
              p.category.toLowerCase() == 'hotel' ||
              p.category.toLowerCase() == 'accommodation')
          .toList();

      final restaurants = allNearbyPlaces
          .where((p) =>
              p.category.toLowerCase() == 'restaurant' ||
              p.category.toLowerCase() == 'cafe')
          .toList();

      setState(() {
        nearbyPlaces = attractions.take(10).toList(); // Limit to 10 items
        nearbyHotels = hotels.take(10).toList();
        nearbyRestaurants = restaurants.take(10).toList();
        loadingNearby = false;
      });
    } catch (error) {
      setState(() {
        loadingNearby = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading nearby places: $error')),
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
                                _openMapWithLocation(
                                    context, place!.location, place!.name);
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
                                          '${place!.location.latitude.toStringAsFixed(4)}, ${place!.location.longitude.toStringAsFixed(4)}',
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
                                        color:
                                            index < place!.averageRating.floor()
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
                        child: DertamButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PlanNewTripScreen()));
                            },
                            text: 'Start Planning',
                            buttonType: ButtonType.primary),
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
                                Expanded(
                                  child: Text(
                                    'Opening Hours: ${place!.openingHours}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                                    _openMapWithLocation(
                                        context, place!.location, place!.name);
                                  },
                                  child: const Text('View on Google Maps'),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.monetization_on),
                                const SizedBox(width: 8),
                                Text(
                                  'Entrance Fee: \$${place!.entranceFees.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Nearby Attractions Section
                      _buildSectionTitle('Attractions nearby'),
                      loadingNearby
                          ? const Center(child: CircularProgressIndicator())
                          : nearbyPlaces.isEmpty
                              ? const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('No nearby attractions found'),
                                )
                              : SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: nearbyPlaces.length,
                                    itemBuilder: (context, index) {
                                      final nearbyPlace = nearbyPlaces[index];
                                      return _buildPlaceCard(
                                        nearbyPlace.name,
                                        nearbyPlace.averageRating,
                                        nearbyPlace.imageURL,
                                        onTap: () => _navigateToPlaceDetail(
                                            nearbyPlace.id),
                                        // Calculate distance from current place
                                        distance: _calculateDistance(
                                          place!.location,
                                          nearbyPlace.location,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                      // Hotels section
                      _buildSectionTitle('Hotels Nearby'),
                      loadingNearby
                          ? const Center(child: CircularProgressIndicator())
                          : nearbyHotels.isEmpty
                              ? const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('No nearby hotels found'),
                                )
                              : SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: nearbyHotels.length,
                                    itemBuilder: (context, index) {
                                      final hotel = nearbyHotels[index];
                                      return _buildHotelCard(
                                        hotel.name,
                                        hotel.averageRating,
                                        hotel.description.length > 50
                                            ? '${hotel.description.substring(0, 50)}...'
                                            : hotel.description,
                                        imageUrl: hotel.imageURL,
                                        onTap: () =>
                                            _navigateToPlaceDetail(hotel.id),
                                        distance: _calculateDistance(
                                          place!.location,
                                          hotel.location,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                      // Restaurants section
                      _buildSectionTitle('Restaurants Nearby'),
                      loadingNearby
                          ? const Center(child: CircularProgressIndicator())
                          : nearbyRestaurants.isEmpty
                              ? const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('No nearby restaurants found'),
                                )
                              : SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: nearbyRestaurants.length,
                                    itemBuilder: (context, index) {
                                      final restaurant =
                                          nearbyRestaurants[index];
                                      return _buildRestaurantCard(
                                        restaurant.name,
                                        // Format the distance as location
                                        '${_calculateDistance(place!.location, restaurant.location).toStringAsFixed(1)} km away',
                                        restaurant.averageRating,
                                        imageUrl: restaurant.imageURL,
                                        onTap: () => _navigateToPlaceDetail(
                                            restaurant.id),
                                      );
                                    },
                                  ),
                                ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  // Helper method to calculate distance between two GeoPoints
  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert latitude and longitude from degrees to radians
    final lat1 = point1.latitude * (3.14159 / 180);
    final lon1 = point1.longitude * (3.14159 / 180);
    final lat2 = point2.latitude * (3.14159 / 180);
    final lon2 = point2.longitude * (3.14159 / 180);

    // Haversine formula
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Helper method to open Google Maps with a location
  void _openMapWithLocation(
      BuildContext context, GeoPoint location, String placeName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapNavigationScreen(
          destinationLocation: location,
          destinationName: placeName,
        ),
      ),
    );
  }

  // Helper method to navigate to another place detail page
  void _navigateToPlaceDetail(String placeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailEachPlace(placeId: placeId),
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

  Widget _buildPlaceCard(
    String title,
    double rating,
    String imageUrl, {
    required Function() onTap,
    required double distance,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.jpg',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${distance.toStringAsFixed(1)} km away',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${rating.toStringAsFixed(1)}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(
    String name,
    double rating,
    String description, {
    required String imageUrl,
    required Function() onTap,
    required double distance,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.jpg',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Text(' ${rating.toStringAsFixed(1)}'),
                      const Spacer(),
                      Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    String name,
    String location,
    double rating, {
    required String imageUrl,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.jpg',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Text(' ${rating.toStringAsFixed(1)}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add these imports at the top

// Extension for PlaceProvider to expose the nearby places functionality
extension PlaceProviderExtension on PlaceProvider {
  Future<List<Place>> findPlacesNearLocation(
      GeoPoint location, double radiusInKm) async {
    try {
      // Get the repository
      final repository = PlaceFirebaseRepository();

      // Get all places
      final List<Place> allPlaces = await repository.fetchAllPlaces();

      // Filter places within the radius
      final List<Place> nearbyPlaces = allPlaces.where((place) {
        double distance = _calculateDistance(location, place.location);
        return distance <= radiusInKm;
      }).toList();

      // Sort by distance from the given location
      nearbyPlaces.sort((a, b) {
        double distanceA = _calculateDistance(location, a.location);
        double distanceB = _calculateDistance(location, b.location);
        return distanceA.compareTo(distanceB);
      });

      return nearbyPlaces;
    } catch (e) {
      throw Exception('Error finding places near location: $e');
    }
  }

  // Calculate distance between two GeoPoints using Haversine formula
  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert latitude and longitude from degrees to radians
    final lat1 = point1.latitude * (pi / 180);
    final lon1 = point1.longitude * (pi / 180);
    final lat2 = point2.latitude * (pi / 180);
    final lon2 = point2.longitude * (pi / 180);

    // Haversine formula
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
