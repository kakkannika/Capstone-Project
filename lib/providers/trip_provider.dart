import 'package:flutter/foundation.dart';
import 'package:tourism_app/services/trip_service.dart';
import 'package:tourism_app/models/trip_model/trip.dart';
import 'package:tourism_app/models/place_model.dart';

class TripViewModel with ChangeNotifier {
  final TripService _tripService = TripService();

  List<Trip> _trips = [];
  Trip? _selectedTrip;
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch trips for the current user
  Future<void> fetchTripsForCurrentUser() async {
    _setLoading(true);
    _error = null;

    try {
      _trips = await _tripService.getTripsForCurrentUser();
    } catch (e) {
      _error = 'Error fetching trips: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Create a trip for the current user
  Future<String?> createTrip({
    required String tripName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final tripId = await _tripService.createTrip(
        tripName: tripName,
        startDate: startDate,
        endDate: endDate,
      );
      await fetchTripsForCurrentUser(); // Refresh the trip list
      return tripId;
    } catch (e) {
      _error = 'Error creating trip: $e';
      print(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Select a trip to view/edit
  Future<void> selectTrip(String tripId) async {
    _setLoading(true);
    _error = null;

    try {
      _selectedTrip = await _tripService.getTripById(tripId);
      notifyListeners();
    } catch (e) {
      _error = 'Error selecting trip: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Get places for a specific day
  Future<List<Place>> getPlacesForDay(String dayId) async {
    if (_selectedTrip == null) {
      throw Exception('No trip selected');
    }

    try {
      return await _tripService.getPlacesForDay(
        tripId: _selectedTrip!.id,
        dayId: dayId,
      );
    } catch (e) {
      _error = 'Error fetching places for day: $e';
      print(_error);
      return [];
    }
  }

  // Add a place to a specific day
  Future<void> addPlaceToDay({
    required String dayId,
    required String placeId,
  }) async {
    if (_selectedTrip == null) {
      throw Exception('No trip selected');
    }

    _setLoading(true);
    _error = null;

    try {
      await _tripService.addPlaceToDay(
        tripId: _selectedTrip!.id,
        dayId: dayId,
        placeId: placeId,
      );
      await selectTrip(_selectedTrip!.id); // Refresh the selected trip
    } catch (e) {
      _error = 'Error adding place to day: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Remove a place from a day
  Future<void> removePlaceFromDay({
    required String dayId,
    required String placeId,
  }) async {
    if (_selectedTrip == null) {
      throw Exception('No trip selected');
    }

    _setLoading(true);
    _error = null;

    try {
      await _tripService.removePlaceFromDay(
        tripId: _selectedTrip!.id,
        dayId: dayId,
        placeId: placeId,
      );
      await selectTrip(_selectedTrip!.id); // Refresh the selected trip
    } catch (e) {
      _error = 'Error removing place from day: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Update a trip's basic information
  Future<void> updateTrip({
    required String tripId,
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _tripService.updateTrip(
        tripId: tripId,
        tripName: tripName,
        startDate: startDate,
        endDate: endDate,
      );
      
      // Refresh the trips list
      await fetchTripsForCurrentUser();
      
      // If this is the currently selected trip, refresh it
      if (_selectedTrip != null && _selectedTrip!.id == tripId) {
        await selectTrip(tripId);
      }
    } catch (e) {
      _error = 'Error updating trip: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    _setLoading(true);
    _error = null;

    try {
      await _tripService.deleteTrip(tripId);
      
      // Refresh the trips list
      await fetchTripsForCurrentUser();
      
      // If this was the selected trip, clear it
      if (_selectedTrip != null && _selectedTrip!.id == tripId) {
        clearSelectedTrip();
      }
    } catch (e) {
      _error = 'Error deleting trip: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clear selected trip
  void clearSelectedTrip() {
    _selectedTrip = null;
    notifyListeners();
  }
}