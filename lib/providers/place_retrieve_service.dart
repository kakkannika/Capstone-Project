// ignore_for_file: unnecessary_null_comparison, cast_from_null_always_fails, avoid_print

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/models/place/place_category.dart';

class PlaceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'places';

  // State variables
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Place> get places => _places;
  List<Place> get filteredPlaces => _filteredPlaces;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor - can load data initially
  PlaceProvider() {
    getAllPlaces();
  }

  // Reset error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get all places
  Future<void> getAllPlaces() async {
    _setLoading(true);
    _clearError();
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(_collection).get();
      _places =
          querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
      _filteredPlaces = List.from(_places);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load places: ${e.toString()}';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Get place by ID
  Future<Place?> getPlaceById(String id) async {
    _setLoading(true);
    _clearError();
    try {
      // First check if it's already in our list
      Place? place = _places.firstWhere((place) => place.id == id,
          orElse: () => null as Place);
      if (place != null) {
        return place;
      }
      // If not, fetch from Firestore
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        return Place.fromFirestore(doc);
      } else {
        _error = 'No place found with ID: $id';
        return null;
      }
    } catch (e) {
      _error = 'Error getting place by ID: ${e.toString()}';
      print(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Filter places by category
  void filterByCategory(PlaceCategory category) {
    _filteredPlaces =
        _places.where((place) => place.category == category).toList();
    notifyListeners();
  }

  // Get places by category
  Future<void> getPlacesByCategory(PlaceCategory category) async {
    _setLoading(true);
    _clearError();
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category.index)
          .get();
      _filteredPlaces =
          querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Error getting places by category: ${e.toString()}';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Get top-rated places
  Future<void> getTopRatedPlaces({int limit = 10}) async {
    _setLoading(true);
    _clearError();
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();
      _filteredPlaces =
          querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Error getting top-rated places: ${e.toString()}';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Search places by name
  void searchPlacesByName(String query) {
    if (query.isEmpty) {
      _filteredPlaces = List.from(_places);
    } else {
      _filteredPlaces = _places
          .where(
              (place) => place.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Add a new place
  Future<String?> addPlace(Place place) async {
    _setLoading(true);
    _clearError();

    try {
      DocumentReference docRef =
          await _firestore.collection(_collection).add(place.toMap());
      String newId = docRef.id;

      // Add to local list with the new ID
      Place newPlace = Place(
        id: newId,
        name: place.name,
        province: place.province,
        description: place.description,
        location: place.location,
        imageURL: place.imageURL,
        category: place.category,
        entranceFees: place.entranceFees,
        openingHours: place.openingHours,
        averageRating: place.averageRating,
      );
      _places.add(newPlace);
      _filteredPlaces = List.from(_places);
      notifyListeners();
      return newId;
    } catch (e) {
      _error = 'Error adding place: ${e.toString()}';
      print(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing place
  Future<bool> updatePlace(Place place) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore
          .collection(_collection)
          .doc(place.id)
          .update(place.toMap());

      // Update in local list
      int index = _places.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _places[index] = place;

        // Update filtered list if needed
        int filteredIndex = _filteredPlaces.indexWhere((p) => p.id == place.id);
        if (filteredIndex != -1) {
          _filteredPlaces[filteredIndex] = place;
        }

        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error updating place: ${e.toString()}';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a place
  Future<bool> deletePlace(String id) async {
    _setLoading(true);
    _clearError();
    try {
      await _firestore.collection(_collection).doc(id).delete();
      // Remove from local lists
      _places.removeWhere((place) => place.id == id);
      _filteredPlaces.removeWhere((place) => place.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting place: ${e.toString()}';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Listen to real-time updates for all places
  void setupPlacesListener() {
    _firestore.collection(_collection).snapshots().listen((snapshot) {
      _places = snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
      _filteredPlaces = List.from(_places);
      notifyListeners();
    }, onError: (e) {
      _error = 'Error in places listener: ${e.toString()}';
      print(_error);
    });
  }

  // Find places near location
  void findPlacesNearLocation(GeoPoint location, double radiusInKm) {
    // Basic implementation - ideally use a specialized geo library
    _filteredPlaces = _places.where((place) {
      double distance = _calculateDistance(
          location.latitude,
          location.longitude,
          place.location.latitude,
          place.location.longitude);
      return distance <= radiusInKm;
    }).toList();

    notifyListeners();
  }

  // Helper function to calculate distance using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * Earth radius (6371 km)
  }

  // Clear filters and show all places
  void clearFilters() {
    _filteredPlaces = List.from(_places);
    notifyListeners();
  }
}
