import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final List<String> imageURL;
  final PlaceCategory category;
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

  // Convert a Place object into a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'imageURL': imageURL,
      'category': category.toString().split('.').last, // Convert enum to string
      'averageRating': averageRating,
      'entranceFees': entranceFees,
      'openingHours': openingHours,
    };
  }

  // Create a Place object from a Firestore document
  factory Place.fromMap(Map<String, dynamic> data, String documentId) {
    return Place(
      id: documentId,
      name: data['name'],
      description: data['description'],
      location: GeoPoint(
        data['location']['latitude'],
        data['location']['longitude'],
      ),
      imageURL: List<String>.from(data['imageURL']),
      category: _parseCategory(data['category']),
      averageRating: data['averageRating'],
      entranceFees: data['entranceFees'],
      openingHours: data['openingHours'],
    );
  }

  // Helper method to convert a string to PlaceCategory enum
  static PlaceCategory _parseCategory(String category) {
    switch (category) {
      case 'historical_place':
        return PlaceCategory.historical_place;
      case 'museum':
        return PlaceCategory.museum;
      case 'market':
        return PlaceCategory.market;
      case 'entertain_attraction':
        return PlaceCategory.entertain_attraction; // Add this case
      default:
        throw ArgumentError('Unknown category: $category');
    }
  }
}

enum PlaceCategory {
  historical_place,
  museum,
  market,
  entertain_attraction, // Add this enum value
}