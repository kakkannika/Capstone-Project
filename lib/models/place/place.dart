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
    return Place(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      location: data['location'],
      imageURL: data['imageURL'],
      category: data['category'],
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
      'imageUrls': imageURL,
      'category': category,
      'entranceFee': entranceFees,
      'openingHours': openingHours,
      'averageRating': averageRating,
    };
  }
}
