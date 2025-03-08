import 'package:flutter/foundation.dart';
import 'package:tourism_app/models/place_model.dart';
import 'package:tourism_app/services/place_service.dart';

class PlaceProvider with ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  
  // State variables
  List<Place> _popularPlaces = [];
  List<Place> _explorePlaces = [];
  List<Place> _weekendTripPlaces = [];
  
  // Loading states
  bool _isLoadingPopular = false;
  bool _isLoadingExplore = false;
  bool _isLoadingWeekendTrips = false;
  
  // Getters
  List<Place> get popularPlaces => _popularPlaces;
  List<Place> get explorePlaces => _explorePlaces;
  List<Place> get weekendTripPlaces => _weekendTripPlaces;
  
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingExplore => _isLoadingExplore;
  bool get isLoadingWeekendTrips => _isLoadingWeekendTrips;
  
  bool get isLoading => _isLoadingPopular || _isLoadingExplore || _isLoadingWeekendTrips;
  
  // Fetch popular places
  Future<void> fetchPopularPlaces({int limit = 6}) async {
    print('Fetching popular places...');
    _isLoadingPopular = true;
    notifyListeners();
    
    try {
      _popularPlaces = await _placeService.getPopularPlaces(limit: limit);
      print('Popular places fetched: ${_popularPlaces.length}');
      print('First popular place: ${_popularPlaces.isNotEmpty ? _popularPlaces[0].name : "none"}');
    } catch (e) {
      print('Error in PlaceProvider.fetchPopularPlaces: $e');
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }
  
  // Fetch explore places (random selection)
  Future<void> fetchExplorePlaces({int limit = 6}) async {
    print('Fetching explore places...');
    _isLoadingExplore = true;
    notifyListeners();
    
    try {
      _explorePlaces = await _placeService.getRandomPlaces(limit: limit);
      print('Explore places fetched: ${_explorePlaces.length}');
      print('First explore place: ${_explorePlaces.isNotEmpty ? _explorePlaces[0].name : "none"}');
    } catch (e) {
      print('Error in PlaceProvider.fetchExplorePlaces: $e');
    } finally {
      _isLoadingExplore = false;
      notifyListeners();
    }
  }
  
  // Fetch weekend trip places (another random selection)
  Future<void> fetchWeekendTripPlaces({int limit = 4}) async {
    print('Fetching weekend trip places...');
    _isLoadingWeekendTrips = true;
    notifyListeners();
    
    try {
      _weekendTripPlaces = await _placeService.getRandomPlaces(limit: limit);
      print('Weekend trip places fetched: ${_weekendTripPlaces.length}');
      print('First weekend trip place: ${_weekendTripPlaces.isNotEmpty ? _weekendTripPlaces[0].name : "none"}');
    } catch (e) {
      print('Error in PlaceProvider.fetchWeekendTripPlaces: $e');
    } finally {
      _isLoadingWeekendTrips = false;
      notifyListeners();
    }
  }
  
  // Fetch all data for home screen
  Future<void> fetchHomeScreenData() async {
    print('Starting to fetch home screen data...');
    await Future.wait([
      fetchPopularPlaces(),
      fetchExplorePlaces(),
      fetchWeekendTripPlaces(),
    ]);
    print('Finished fetching all home screen data');
  }
  
  // Get place by ID
  Future<Place?> getPlaceById(String id) async {
    return await _placeService.getPlaceById(id);
  }
} 