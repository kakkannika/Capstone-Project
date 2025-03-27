import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import 'place.dart';

class Province {
  final String name;
  final List<Place> places;

  Province({
    required this.name,
    required this.places,
  });

  // Factory constructor to create a Province from a Firestore document
  factory Province.fromFirestore(firestore.QueryDocumentSnapshot<Map<String, dynamic>> doc,
    List<Place> places,) {
    return Province(
      name: doc['name'] as String,
      places: (doc['places'] as List<dynamic>)
          .map((place) => Place.fromFirestore(place))
          .toList(),
    );
  }
}
