// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourism_app/models/place/place.dart';

class PlaceCrudService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'places';

  set firestore(FirebaseFirestore firestore) {}

  // Add a new place
  // Function to add a new place
  Future<String?> addPlace(Place place) async {
    try {
      final CollectionReference places = _firestore.collection(collectionName);
      DocumentReference docRef = await places.add({
        'name': place.name,
        'description': place.description,
        'province': place.province,
        'location': GeoPoint(place.location.latitude, place.location.longitude),
        'imageURL': place.imageURL,
        'category': place.category,
        'averageRating': place.averageRating,
        'entranceFees': place.entranceFees,
        'openingHours': place.openingHours,
      });
      notifyListeners(); // Notify listeners after adding a place
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding place: $e');
      return null;
    }
  }

  // Update an existing place
  Future<String?> updatePlace(Place place) async {
    try {
      await _firestore.collection(collectionName).doc(place.id).update({
        'name': place.name,
        'description': place.description,
        'province': place.province,
        'location': place.location,
        'imageURL': place.imageURL,
        'category': place.category,
        'averageRating': place.averageRating,
        'entranceFees': place.entranceFees,
        'openingHours': place.openingHours,
      });

      notifyListeners();
      return place.id;
    } catch (e) {
      print('Error updating place: $e');
      return null;
    }
  }

  // Delete a place
  Future<bool> deletePlace(String placeId) async {
    try {
      await _firestore.collection(collectionName).doc(placeId).delete();

      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting place: $e');
      return false;
    }
  }

  // Search places by name
  Future<List<Place>> searchPlacesByName(String query) async {
    try {
      // Firestore doesn't support direct LIKE queries, so we use range queries
      // This searches for places where name starts with the query
      QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Place(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          province: data['province'] ?? '',
          location: data['location'] as GeoPoint,
          imageURL: data['imageURL'] ?? '',
          category: data['category'] ?? '',
          averageRating: (data['averageRating'] ?? 0.0).toDouble(),
          entranceFees: (data['entranceFees'] ?? 0.0).toDouble(),
          openingHours: data['openingHours'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
}
