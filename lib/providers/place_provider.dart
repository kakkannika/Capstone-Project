import 'package:flutter/material.dart';
import 'package:tourism_app/repository/firebase/place_firebase_repository.dart';
import 'package:tourism_app/models/place/place.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceFirebaseRepository _placeRepository = PlaceFirebaseRepository();

  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }

  Future<void> fetchAllPlaces() async {
    _setLoading(true);
    try {
      _places = await _placeRepository.fetchAllPlaces();
      _setError(null);
    } catch (e) {
      _setError('Failed to fecth places');
    }
    _setLoading(false);
  }

  Future<Place?> getPlaceById(String placeId) async {
    _setLoading(true);
    try {
      final place = await _placeRepository.getPlaceById(placeId);
      return place;
    } catch (e) {
      _setError('Error fetching place: $e');
    }
    _setLoading(false);
    return null;
  }

  Future<void> fetchPlacesByCategory(String category) async {
    _setLoading(true);
    try {
      _places = await _placeRepository.fetchPlacesByCategory(category);
      _setError(null);
    } catch (e) {
      _setError('Failed to fetch places by category');
    }
    _setLoading(false);
  }

  Future<void> fetchHighlyRatedPlaces(double minRating) async {
    _setLoading(true);
    try {
      _places = await _placeRepository.fetchHightlyRatedPlaces(minRating);
      _setError(null);
    } catch (e) {
      _setError('Failed to fetch places by highly rating');
    }
    _setLoading(false);
  }

  Future<void> searchPlace(String query) async {
    _setLoading(true);
    try {
      _places = await _placeRepository.searchPlaces(query);
    } catch (e) {
      throw Exception('Faile to search places');
    }
  }
}
