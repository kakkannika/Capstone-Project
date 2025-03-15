// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/models/trips/trip_days.dart';
import 'package:tourism_app/models/trips/trips.dart';

class TripService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID
  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User is not logged in');
    }
  }

  // Create a trip for the current user
  Future<String> createTrip({
    required String tripName,
    required DateTime startDate,
    required DateTime endDate,
    String? budgetId,
  }) async {
    try {
      final userId = getCurrentUserId();

      // Create the trip document
      final tripRef = _firestore.collection('trips').doc();
      await tripRef.set({
        'userId': userId,
        'tripName': tripName,
        'startDate': firestore.Timestamp.fromDate(startDate),
        'endDate': firestore.Timestamp.fromDate(endDate),
        'budgetId': budgetId,
      });

      // Create days subcollection with specific IDs (day1, day2, etc.)
      final numberOfDays = endDate.difference(startDate).inDays + 1;
      for (int i = 1; i <= numberOfDays; i++) {
        await tripRef.collection('days').doc('day$i').set({
          'dayNumber': i,
          'placeIds': [], // Initialize empty list of place IDs
        });
      }

      print('Trip created successfully with $numberOfDays days');
      return tripRef.id;
    } catch (e) {
      print('Error creating trip: $e');
      throw Exception('Failed to create trip: $e');
    }
  }

  // Get a specific trip by ID
  Future<Trip?> getTripById(String tripId) async {
    try {
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      
      if (!tripDoc.exists) {
        return null;
      }

      final days = await _fetchDaysForTrip(tripDoc.reference);
      return Trip.fromFirestore(tripDoc, days);
    } catch (e) {
      print('Error fetching trip: $e');
      rethrow;
    }
  }

  // Fetch trips for the current user
  Future<List<Trip>> getTripsForCurrentUser() async {
    try {
      final userId = getCurrentUserId();

      final tripsSnapshot = await _firestore
          .collection('trips')
          .where('userId', isEqualTo: userId)
          .get();

      final List<Trip> trips = [];
      for (final tripDoc in tripsSnapshot.docs) {
        final days = await _fetchDaysForTrip(tripDoc.reference);
        trips.add(Trip.fromFirestore(tripDoc, days));
      }

      print('Fetched ${trips.length} trips for user $userId');
      return trips;
    } catch (e) {
      print('Error fetching trips for user: $e');
      rethrow;
    }
  }

  // Fetch days for a specific trip
  Future<List<Day>> _fetchDaysForTrip(firestore.DocumentReference tripRef) async {
    try {
      final daysSnapshot = await tripRef.collection('days')
          .orderBy('dayNumber')
          .get();
      
      final List<Day> days = [];
      for (final dayDoc in daysSnapshot.docs) {
        final data = dayDoc.data();
        final List<String> placeIds = List<String>.from(data['placeIds'] ?? []);
        final places = await _fetchPlacesFromMainCollection(placeIds);
        days.add(Day.fromFirestore(dayDoc, places, placeIds));
      }

      return days;
    } catch (e) {
      print('Error fetching days for trip: $e');
      rethrow;
    }
  }

  // Fetch places from the main places collection
  Future<List<Place>> _fetchPlacesFromMainCollection(List<String> placeIds) async {
    try {
      final List<Place> places = [];
      for (final placeId in placeIds) {
        final doc = await _firestore.collection('places').doc(placeId).get();
        if (doc.exists) {
          places.add(Place.fromFirestore(doc));
        }
      }
      return places;
    } catch (e) {
      print('Error fetching places: $e');
      return [];
    }
  }
  // Add a place to a day
  Future<void> addPlaceToDay({
    required String tripId,
    required String dayId,  // Should be in format 'day1', 'day2', etc.
    required String placeId,
  }) async {
    try {
      final dayRef = _firestore
          .collection('trips')
          .doc(tripId)
          .collection('days')
          .doc(dayId);
          

      // Get current placeIds array
      final dayDoc = await dayRef.get();
      final currentPlaceIds = List<String>.from(dayDoc.data()?['placeIds'] ?? []);

      // Add new placeId if it doesn't exist
      if (!currentPlaceIds.contains(placeId)) {
        currentPlaceIds.add(placeId);
        await dayRef.update({
          'placeIds': currentPlaceIds,
        });
      }

      print('Place $placeId added to $dayId in trip $tripId');
    } catch (e) {
      print('Error adding place to day: $e');
      rethrow;
    }
  }

  // Remove a place from a day
  Future<void> removePlaceFromDay({
    required String tripId,
    required String dayId,
    required String placeId,
  }) async {
    try {
      final dayRef = _firestore
          .collection('trips')
          .doc(tripId)
          .collection('days')
          .doc(dayId);

      // Get current placeIds array
      final dayDoc = await dayRef.get();
      final currentPlaceIds = List<String>.from(dayDoc.data()?['placeIds'] ?? []);

      // Remove placeId if it exists
      if (currentPlaceIds.contains(placeId)) {
        currentPlaceIds.remove(placeId);
        await dayRef.update({
          'placeIds': currentPlaceIds,
        });
      }

      print('Place $placeId removed from $dayId in trip $tripId');
    } catch (e) {
      print('Error removing place from day: $e');
      rethrow;
    }
  }

  // Get places for a specific day in a trip
  Future<Object> getPlacesForDay({
    required String tripId,
    required String dayId,
  }) async {
    try {
      final dayDoc = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('days')
          .doc(dayId)
          .get();

      if (!dayDoc.exists) {
        return [];
      }

      final placeIds = List<String>.from(dayDoc.data()?['placeIds'] ?? []);
      return _fetchPlacesFromMainCollection(placeIds);
    } catch (e) {
      print('Error fetching places for day: $e');
      rethrow;
    }
  }

  // Update a trip's basic information
  Future<void> updateTrip({
    required String tripId,
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final tripRef = _firestore.collection('trips').doc(tripId);
      
      // Get the current trip data
      final tripDoc = await tripRef.get();
      if (!tripDoc.exists) {
        throw Exception('Trip not found');
      }
      
      final Map<String, dynamic> updateData = {};
      
      // Only update fields that are provided
      if (tripName != null) {
        updateData['tripName'] = tripName;
      }
      
      if (startDate != null) {
        updateData['startDate'] = firestore.Timestamp.fromDate(startDate);
      }
      
      if (endDate != null) {
        updateData['endDate'] = firestore.Timestamp.fromDate(endDate);
      }
      
      // If there's nothing to update, return early
      if (updateData.isEmpty) {
        return;
      }
      
      // Update the trip document
      await tripRef.update(updateData);
      
      // If the end date is extended, we may need to add more days
      if (endDate != null) {
        final currentEndDate = (tripDoc.data()?['endDate'] as firestore.Timestamp).toDate();
        final currentStartDate = (tripDoc.data()?['startDate'] as firestore.Timestamp).toDate();
        
        // If the new end date is later than the current one
        if (endDate.isAfter(currentEndDate)) {
          // Calculate the current number of days
          final currentNumberOfDays = currentEndDate.difference(currentStartDate).inDays + 1;
          
          // Calculate the new number of days
          final newNumberOfDays = endDate.difference(startDate ?? currentStartDate).inDays + 1;
          
          // If we need to add more days
          if (newNumberOfDays > currentNumberOfDays) {
            // Add the new days
            for (int i = currentNumberOfDays + 1; i <= newNumberOfDays; i++) {
              await tripRef.collection('days').doc('day$i').set({
                'dayNumber': i,
                'placeIds': [], // Initialize empty list of place IDs
              });
            }
          }
        }
      }
      
      print('Trip $tripId updated successfully');
    } catch (e) {
      print('Error updating trip: $e');
      rethrow;
    }
  }
  
  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    try {
      final tripRef = _firestore.collection('trips').doc(tripId);
      
      // First, get all days in the trip
      final daysSnapshot = await tripRef.collection('days').get();
      
      // Delete each day document
      for (final dayDoc in daysSnapshot.docs) {
        await dayDoc.reference.delete();
      }
      
      // Then delete the trip document itself
      await tripRef.delete();
      
      print('Trip $tripId deleted successfully');
    } catch (e) {
      print('Error deleting trip: $e');
      rethrow;
    }
  }
  
  // Get a stream of trips for the current user
  Stream<List<Trip>> getTripsStream() {
    try {
      final userId = getCurrentUserId();
      
      return _firestore
          .collection('trips')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .asyncMap((snapshot) async {
            final List<Trip> trips = [];
            
            for (final tripDoc in snapshot.docs) {
              final days = await _fetchDaysForTrip(tripDoc.reference);
              trips.add(Trip.fromFirestore(tripDoc, days));
            }
            
            return trips;
          });
    } catch (e) {
      print('Error getting trips stream: $e');
      rethrow;
    }
  }
  
  // Get a stream of places for a specific day in a trip
  Stream<List<Place>> getPlacesForDayStream({
    required String tripId,
    required String dayId,
  }) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('days')
        .doc(dayId)
        .snapshots()
        .asyncMap((dayDoc) async {
          if (!dayDoc.exists) {
            return [];
          }
          
          final placeIds = List<String>.from(dayDoc.data()?['placeIds'] ?? []);
          return await _fetchPlacesFromMainCollection(placeIds);
        });
  }
  
  // Get a stream for a specific trip by ID
  Stream<Trip?> getTripByIdStream(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .asyncMap((tripDoc) async {
          if (!tripDoc.exists) {
            return null;
          }
          
          final days = await _fetchDaysForTrip(tripDoc.reference);
          return Trip.fromFirestore(tripDoc, days);
        });
  }

  // Update a trip's budget ID
  Future<void> updateTripBudgetId({
    required String tripId,
    required String budgetId,
  }) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'budgetId': budgetId,
      });
    } catch (e) {
      print('Error updating trip budget ID: $e');
      throw Exception('Failed to update trip budget ID: $e');
    }
  }

  // Remove a trip's budget ID
  Future<void> removeTripBudgetId(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'budgetId': firestore.FieldValue.delete(),
      });
    } catch (e) {
      print('Error removing trip budget ID: $e');
      throw Exception('Failed to remove trip budget ID: $e');
    }
  }

  // Get a trip's budget ID
  Future<String?> getTripBudgetId(String tripId) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['budgetId'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting trip budget ID: $e');
      throw Exception('Failed to get trip budget ID: $e');
    }
  }
}

