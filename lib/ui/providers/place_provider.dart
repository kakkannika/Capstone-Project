import 'package:flutter/material.dart';
import 'package:tourism_app/data/repository/place_repository.dart';
import 'package:tourism_app/domain/models/place/place.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceRepository _placeRepository;
  PlaceProvider(this._placeRepository) {
    // Initialize the provider by fetching all places
    fetchAllPlaces();
  }

  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  // Track the current filtered province
  String? _currentProvince;
  
  // Get the current province filter
  String? get currentProvince => _currentProvince;

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

  Future<void> filterByProvince(String provinceName) async {
    _setLoading(true);
    _currentProvince = provinceName; // Store the current province
    notifyListeners();
    try {
      _places = await _placeRepository.fetchPlacesByProvince(provinceName);
    } catch (e) {
      _setError('Failed to filter places by province: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
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

  Future<List<Place?>> fetchPlacesByCategory(
      String category, String province) async {
    _setLoading(true);
    try {
      _places =
          await _placeRepository.fetchPlacesByCategory(category, province);
      _setError(null);
    } catch (e) {
      _setError('Failed to fetch places by category');
    }
    _setLoading(false);
    return _places;
  }

  Future<List<Place>> fetchHighlyRatedPlaces(
      double minRating, String province) async {
    _setLoading(true);
    try {
      _places =
          await _placeRepository.fetchHightlyRatedPlaces(minRating, province);
      _setError(null);
    } catch (e) {
      _setError('Failed to fetch places by highly rating');
    }
    notifyListeners();
    return _places;
  }

  Future<void> searchPlace(String query) async {
    _setLoading(true);
    try {
      if (_currentProvince != null && _currentProvince!.isNotEmpty) {
        // If a province filter is active, search within that province
        if (query.isEmpty) {
          // If query is empty, just show all places in the province
          _places = await _placeRepository.fetchPlacesByProvince(_currentProvince!);
        } else {
          // Search with both query and province filter
          _places = await _placeRepository.searchPlacesInProvince(query, _currentProvince!);
        }
      } else {
        // Standard search across all provinces
        _places = await _placeRepository.searchPlaces(query);
      }
      _setError(null);
    } catch (e) {
      _setError('Failed to search places: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> searchInProvince(String query, String province) async {
    _setLoading(true);
    try {
      if (query.isEmpty) {
        // If query is empty but province is specified, just show all places in that province
        _places = await _placeRepository.fetchPlacesByProvince(province);
      } else {
        // Search with both query and province filter
        _places = await _placeRepository.searchPlacesInProvince(query, province);
      }
      _setError(null);
    } catch (e) {
      _setError('Failed to search places in province: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addPlace(Place place) async {
    _setLoading(true);
    try {
      final placeId = await _placeRepository.addPlace(place);
      if (placeId != null) {
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to add place');
    }
    _setLoading(false);
  }


  Future<void> updatePlace(Place place) async {
    _setLoading(true);
    try {
      final placeId = await _placeRepository.updatePlace(place);
      if (placeId != null) {
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update place');
    }
    _setLoading(false);
  }


  Future<void> deletePlace(String placeId) async {
    _setLoading(true);
    try {
      final isDeleted = await _placeRepository.deletePlace(placeId);
      if (isDeleted) {
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to delete place');
    }
    _setLoading(false);
  }
}