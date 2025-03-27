// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/data/repository/place_repository.dart';
import 'package:tourism_app/models/place/place.dart';

class PlaceFirebaseRepository extends PlaceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'places';

  // Fetching all places
  @override
  Future<List<Place>> fetchAllPlaces() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();
      return querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching place : $e');
    }
  }

  // Get places by ID
  @override
  Future<Place?> getPlaceById(String placeId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collectionName).doc(placeId).get();
      if (doc.exists) {
        return Place.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching place : $e');
    }
  }

  // Get place by category
  // @override
  // Future<List<Place>> fetchPlacesByCategory(String category) async {
  //   try {
  //     QuerySnapshot querySnapshot = await _firestore
  //         .collection(collectionName)
  //         .where('category', isEqualTo: category)
  //         .get();
  //     return querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
  //   } catch (e) {
  //     throw Exception('Error fetching place by category : $e');
  //   }
  // }

  // // Get popular place
  // @override
  // Future<List<Place>> fetchHightlyRatedPlaces(double minRating, String province) async {
  //   try {
  //     QuerySnapshot querySnapshot = await _firestore
  //         .collection(collectionName)
  //         .where('averageRating', isGreaterThanOrEqualTo: minRating).where('province', isEqualTo: province)
  //         .get();
  //     return querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
  //   } catch (e) {
  //     throw Exception('Erorr fetching place by hight rating : $e');
  //   }
  // }

  //
  @override
  Future<List<Place>> searchPlaces(String query) async {
    try {
      // Convert query to lowercase for case-insensitive search
      final queryLower = query.toLowerCase();
      // Get all places from the collection
      final placesSnapshot = await _firestore.collection('places').get();
      // Filter places client-side based on the query
      final List<Place> results = placesSnapshot.docs
          .where((doc) {
            final data = doc.data();
            final name = (data['name'] as String? ?? '').toLowerCase();
            final description =
                (data['description'] as String? ?? '').toLowerCase();

            // Check if the place name or description contains the query
            return name.contains(queryLower) ||
                description.contains(queryLower);
          })
          .map((doc) =>
              Place.fromFirestore(doc)) // Convert Firestore doc to Place object
          .toList();

      return results;
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  // @override
  // Future<List<Place>> fetchPlacesByProvince(String province) async {
  //   try {
  //     final querySnapshot = await _firestore
  //         .collection('places')
  //         .where('province', isEqualTo: province)
  //         .get();

  //     return querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
  //   } catch (e) {
  //     print('Error fetching places: $e');
  //     return [];
  //   }
  // }
}
