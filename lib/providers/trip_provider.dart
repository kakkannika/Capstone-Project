import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/data/repository/trip_repository.dart';

class TripProvider with ChangeNotifier {
  final TripService _tripService = TripService();
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Trip>>? _tripsSubscription;

  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;
  void _setError(String? errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }

  // Get a stream of trips for the current user
  Stream<List<Trip>> getTripsStream() {
    return _tripService.getTripsStream();
  }

  // Get a stream for a specific trip by ID
  Stream<Trip?> getTripByIdStream(String tripId) {
    return _tripService.getTripByIdStream(tripId);
  }

  // Get a stream of places for a specific day
  Stream<List<Place>> getPlacesForDayStream({
    required String tripId,
    required String dayId,
  }) {
    return _tripService.getPlacesForDayStream(
      tripId: tripId,
      dayId: dayId,
    );
  }

  // Start listening to the trips stream
  void startListeningToTrips() {
    _setLoading(true);
    _error = null;

    try {
      // Cancel any existing subscription
      _tripsSubscription?.cancel();

      // Subscribe to the trips stream
      _tripsSubscription = getTripsStream().listen((trips) {
        _trips = trips;
        _setLoading(false);
        notifyListeners();
      }, onError: (e) {
        _setLoading(false);
        notifyListeners();
        _setError('Error fetching trips : $e');
      });
    } catch (e) {
      _setLoading(false);
      notifyListeners();
      _setError('Error setting up trips stream: $e');
    }
  }

  // Stop listening to the trips stream
  void stopListeningToTrips() {
    _tripsSubscription?.cancel();
    _tripsSubscription = null;
  }

  // Fetch trips for the current user
  Future<void> fetchTripsForCurrentUser() async {
    _setLoading(true);
    _error = null;

    try {
      _trips = await _tripService.getTripsForCurrentUser();
    } catch (e) {
      _setError('Error fetching trips : $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a trip for the current user
  Future<String?> createTrip({
    required String tripName,
    required DateTime startDate,
    required DateTime endDate,
    String? budgetId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final tripId = await _tripService.createTrip(
        tripName: tripName,
        startDate: startDate,
        endDate: endDate,
        budgetId: budgetId,
      );
      await fetchTripsForCurrentUser(); // Refresh the trip list
      return tripId;
    } catch (e) {
      _setError('Error creating trip: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Select a trip to view/edit
  Future<void> selectTrip(String tripId) async {
    _setLoading(true);
    _setError(null);
    try {
      _selectedTrip = await _tripService.getTripById(tripId);
      notifyListeners();
    } catch (e) {
      _setError('Error selecting trip: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get places for a specific day
  Future<Object> getPlacesForDay(String dayId) async {
    if (_selectedTrip == null) {
      throw Exception('No trip selected');
    }

    try {
      return await _tripService.getPlacesForDay(
        tripId: _selectedTrip!.id,
        dayId: dayId,
      );
    } catch (e) {
      _setError('Error fetching places for day: $e');
      notifyListeners();
      return [];
    }
  }

  // For addPlaceToDay
  Future<void> addPlaceToDay({
    required String dayId,
    required String placeId,
    required VoidCallback onSuccess,
  }) async {
    if (_selectedTrip == null) {
      throw Exception('No trip selected');
    }

    _setLoading(true);
    _setError(null);
    try {
      await _tripService.addPlaceToDay(
        tripId: _selectedTrip!.id,
        dayId: dayId,
        placeId: placeId,
      );

      // Refresh the selected trip immediately
      await selectTrip(_selectedTrip!.id);

      // Then call the success callback
      onSuccess();
      _setLoading(false);
    } catch (e) {
      _setError('Error adding place to day: $e');
    } finally {
      _setLoading(false);
    }
  }

// For removePlaceFromDay
  Future<void> removePlaceFromDay({
    required String dayId,
    required String placeId,
  }) async {
    if (_selectedTrip == null) {
      throw Exception('No trip selected');
    }

    _setLoading(true);
    _setError(null);
    try {
      await _tripService.removePlaceFromDay(
        tripId: _selectedTrip!.id,
        dayId: dayId,
        placeId: placeId,
      );
      _setLoading(false);

      // Just refresh the selected trip - don't call notifyListeners first
      await selectTrip(_selectedTrip!.id);
    } catch (e) {
      _setError('Error removing place from day: $e');
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
      notifyListeners();
      // Refresh the trips list
      await fetchTripsForCurrentUser();

      // If this is the currently selected trip, refresh it
      if (_selectedTrip != null && _selectedTrip!.id == tripId) {
        await selectTrip(tripId);
      }
    } catch (e) {
      _setError('Error updating trip: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _tripService.deleteTrip(tripId);

      // Refresh the trips list
      await fetchTripsForCurrentUser();

      // If this was the selected trip, clear it
      if (_selectedTrip != null && _selectedTrip!.id == tripId) {
        clearSelectedTrip();
      }
    } catch (e) {
      _setError('Error deleting trip: $e');
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

  // Update a trip's budget ID
  Future<bool> updateTripBudgetId({
    required String tripId,
    required String budgetId,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _tripService.updateTripBudgetId(
        tripId: tripId,
        budgetId: budgetId,
      );

      // Update the selected trip if it's the one being modified
      if (_selectedTrip?.id == tripId) {
        _selectedTrip = _selectedTrip!.copyWith(budgetId: budgetId);
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update trip budget ID: $e');
      return false;
    }
  }

  // Remove a trip's budget ID
  Future<bool> removeTripBudgetId(String tripId) async {
    try {
      _setLoading(true);
      _error = null;

      await _tripService.removeTripBudgetId(tripId);

      // Update the selected trip if it's the one being modified
      if (_selectedTrip?.id == tripId) {
        _selectedTrip = _selectedTrip!.copyWith(budgetId: null);
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to remove trip budget ID: $e');
      return false;
    }
  }

  // Get a trip's budget ID
  Future<String?> getTripBudgetId(String tripId) async {
    try {
      return await _tripService.getTripBudgetId(tripId);
    } catch (e) {
      _setError('Failed to get trip budget ID: $e');
      return null;
    }
  }

  @override
  void dispose() {
    stopListeningToTrips();
    super.dispose();
  }
}
