// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final String imageURL;
  final String
      category; // Changed from PlaceCategory to String to match Firestore
  final double averageRating;
  final double entranceFees;
  final String openingHours;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.imageURL,
    required this.category,
    required this.averageRating,
    required this.entranceFees,
    required this.openingHours,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle location which is stored as a string in format "latitude, longitude"
    GeoPoint locationGeoPoint;
    if (data['location'] is String) {
      try {
        final List<String> latLng = (data['location'] as String).split(',');
        double lat = double.parse(latLng[0].trim());
        double lng = double.parse(latLng[1].trim());
        locationGeoPoint = GeoPoint(lat, lng);
      } catch (e) {
        print('Error parsing location string: ${data['location']}');
        locationGeoPoint = GeoPoint(0, 0);
      }
    } else if (data['location'] is GeoPoint) {
      locationGeoPoint = data['location'] as GeoPoint;
    } else {
      locationGeoPoint = GeoPoint(0, 0);
    }

    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: locationGeoPoint,
      imageURL: data['imageURL'] ?? '',
      category: data['category'] ?? '',
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      entranceFees: (data['entranceFees'] ?? 0).toDouble(),
      openingHours: data['openingHours'] ?? '',
    );
  }

  // Helper method to convert a string to PlaceCategory enum
}

enum PlaceCategory {
  historical_place,
  museum,
  market,
  entertain_attraction, // Add this enum value
}
