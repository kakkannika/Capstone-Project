// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
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
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .get();
      
      _places = querySnapshot.docs
          .map((doc) => Place.fromFirestore(doc))
          .toList();
      
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
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(placeId)
          .get();
      
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
      
      _places = querySnapshot.docs
          .map((doc) => Place.fromFirestore(doc))
          .toList();
      
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
      
      _places = querySnapshot.docs
          .map((doc) => Place.fromFirestore(doc))
          .toList();
      
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
}