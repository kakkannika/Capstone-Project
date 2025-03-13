import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/models/place/place.dart';

class PlaceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'places';

  // Fetching all places
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
  Future<List<Place>> fetchPlacesByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('category', isEqualTo: category)
          .get();
      return querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching place by category : $e');
    }
  }

  // Get popular place
  Future<List<Place>> fetchHightlyRatedPlaces(double minRating) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('averageRating', isGreaterThanOrEqualTo: minRating)
          .get();
      return querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erorr fetching place by hight rating : $e');
    }
  }

  //
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
  
  // Future<void> addPlaceToTripDay( firestore.DocumentReference dayRef, String placeId) async {
  //   try {
  //     // Get current placeIds array
  //     final dayDoc = await dayRef.get();
  //     final currentPlaceIds = List<String>.from(
  //         (dayDoc.data() as Map<String, dynamic>?)?['placeId'] ?? []);

  //     // Add new placeId if it doesn't exist
  //     if (!currentPlaceIds.contains(placeId)) {
  //       currentPlaceIds.add(placeId);
  //       await dayRef.update({
  //         'placeIds': currentPlaceIds,
  //       });
  //     }

  //     print('Place $placeId added to trip day');
  //   } catch (e) {
  //     throw Exception('Error adding place to day: $e');
  //   }
  // }


  // Future<void> removePlaceFromTripDay(
  //     firestore.DocumentReference dayRef, String placeId) async {
  //   try {
  //     // Get current placeIds array
  //     final dayDoc = await dayRef.get();
  //     final currentPlaceIds = List<String>.from(
  //         (dayDoc.data() as Map<String, dynamic>?)?['placeIds'] ?? []);

  //     // Remove placeId if it exists
  //     if (currentPlaceIds.contains(placeId)) {
  //       currentPlaceIds.remove(placeId);
  //       await dayRef.update({
  //         'placeIds': currentPlaceIds,
  //       });
  //     }

  //     print('Place $placeId removed from trip day');
  //   } catch (e) {
  //     throw Exception('Error removing place from day: $e');
  //   }
  // }
}
