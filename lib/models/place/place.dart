// Place Model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/models/place/place_category.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final List<String> imageURL;
  final PlaceCategory category;
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
      imageURL: List<String>.from(data['imageURL']),
      category: PlaceCategory.values[data['category']],
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
      'category': category.index,
      'entranceFee': entranceFees,
      'openingHours': openingHours,
      'averageRating': averageRating,
    };
  }
}