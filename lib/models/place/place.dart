// Place Model
import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final String imageURL;
  final String category;
  final double? averageRating;
  final double? entranceFees;
  final String? openingHours;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.imageURL,
    required this.category,
    this.entranceFees,
    this.openingHours,
    this.averageRating,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    GeoPoint locationPoint;
    if (data['location'] is String) {
      final List<String> coordinates = data['location'].toString().split(',');
      final double lat = double.parse(coordinates[0].trim());
      final double lng = double.parse(coordinates[1].trim());
      locationPoint = GeoPoint(lat, lng);
    } else if (data['location'] is GeoPoint) {
      locationPoint = data['location'];
    } else {
      locationPoint = GeoPoint(0, 0);
    }

    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: locationPoint,
      imageURL: data['imageURL'] ?? '',
      category: data['category'] ?? '',
      entranceFees: data['entranceFees']?.toDouble(),
      openingHours: data['openingHours'],
      averageRating: data['averageRating']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'imageURL': imageURL,
      'category': category,
      'entranceFees': entranceFees,
      'openingHours': openingHours,
      'averageRating': averageRating,
    };
  }
}
