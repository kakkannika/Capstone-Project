// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart';
import 'package:tourism_app/models/place/place.dart';

class PlaceProvider with ChangeNotifier {
  final String collectionName = 'places';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;

  get currentUser => null;

  // Fetch all places
  Future<void> fetchAllPlaces() async {
    _setLoading(true);
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();

      _places =
          querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Error fetching places: $e');
    }
  }

  // // Fetch a single place by ID
  Future<Place?> getPlaceById(String placeId) async {
    _setLoading(true);
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collectionName).doc(placeId).get();

      _setLoading(false);
      if (doc.exists) {
        return Place.fromFirestore(doc);
      } else {
        _error = 'No place found with ID: $placeId';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _handleError('Error fetching place: $e');
      return null;
    }
  }

  // // Fetch places by category
  Future<void> fetchPlacesByCategory(String category) async {
    _setLoading(true);
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('category', isEqualTo: category)
          .get();

      _places =
          querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Error fetching places by category: $e');
    }
  }

  // // Fetch highly rated places
  Future<void> fetchHighlyRatedPlaces(double minRating) async {
    _setLoading(true);
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('averageRating', isGreaterThanOrEqualTo: minRating)
          .get();

      _places =
          querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Error fetching highly rated places: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  void _handleError(String errorMsg) {
    print(errorMsg);
    _error = errorMsg;
    _isLoading = false;
    notifyListeners();
  }

  // Add a new place
  Future<String?> addPlace(Place place) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(collectionName).add({
        'name': place.name,
        'description': place.description,
        'location': place.location,
        'imageURL': place.imageURL,
        'category': place.category,
        'averageRating': place.averageRating,
        'entranceFees': place.entranceFees,
        'openingHours': place.openingHours,
      });

      notifyListeners();
      return docRef.id;
    } catch (e) {
      print('Error adding place: $e');
      return null;
    }
  }

  // Update an existing place
  Future<bool> updatePlace(Place place) async {
    try {
      await _firestore.collection(collectionName).doc(place.id).update({
        'name': place.name,
        'description': place.description,
        'location': place.location,
        'imageURL': place.imageURL,
        'category': place.category,
        'averageRating': place.averageRating,
        'entranceFees': place.entranceFees,
        'openingHours': place.openingHours,
      });

      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating place: $e');
      return false;
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
          final description = (data['description'] as String? ?? '').toLowerCase();

          // Check if the place name or description contains the query
          return name.contains(queryLower) || description.contains(queryLower);
        })
        .map((doc) => Place.fromFirestore(doc)) // Convert Firestore doc to Place object
        .toList();

    return results;
  } catch (e) {
    print('Error searching places: $e');
    rethrow;
  }
}


  Future<void> addPlaceToTripDay(
      firestore.DocumentReference dayRef, String placeId) async {
    try {
      // Get current placeIds array
      final dayDoc = await dayRef.get();
      final currentPlaceIds = List<String>.from(
          (dayDoc.data() as Map<String, dynamic>?)?['placeId'] ?? []);

      // Add new placeId if it doesn't exist
      if (!currentPlaceIds.contains(placeId)) {
        currentPlaceIds.add(placeId);
        await dayRef.update({
          'placeIds': currentPlaceIds,
        });
      }

      print('Place $placeId added to trip day');
    } catch (e) {
      print('Error adding place to day: $e');
      rethrow;
    }
  }

  Future<void> removePlaceFromTripDay(
      firestore.DocumentReference dayRef, String placeId) async {
    try {
      // Get current placeIds array
      final dayDoc = await dayRef.get();
      final currentPlaceIds = List<String>.from(
          (dayDoc.data() as Map<String, dynamic>?)?['placeIds'] ?? []);

      // Remove placeId if it exists
      if (currentPlaceIds.contains(placeId)) {
        currentPlaceIds.remove(placeId);
        await dayRef.update({
          'placeIds': currentPlaceIds,
        });
      }

      print('Place $placeId removed from trip day');
    } catch (e) {
      print('Error removing place from day: $e');
      rethrow;
    }
  }
}
