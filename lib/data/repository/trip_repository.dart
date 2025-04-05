import 'package:tourism_app/domain/models/place/place.dart';
import 'package:tourism_app/domain/models/trips/trips.dart';

abstract class TripRepository {
  Future<String> createTrip({
    required String tripName,
    required DateTime startDate,
    required DateTime endDate,
    String? budgetId,
    String? province,
  });

  Future<Trip?> getTripById(String tripId);

  Future<List<Trip>> getTripsForCurrentUser();

  Future<void> addPlaceToDay({
    required String tripId,
    required String dayId, // Should be in format 'day1', 'day2', etc.
    required String placeId,
  });
  Future<void> removePlaceFromDay({
    required String tripId,
    required String dayId,
    required String placeId,
  });

  Future<Object> getPlacesForDay({
    required String tripId,
    required String dayId,
  });

  Future<void> updateTrip({
    required String tripId,
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
    String? province,
  });

  Future<void> deleteTrip(String tripId);

  Stream<List<Trip>> getTripsStream();

  Stream<List<Place>> getPlacesForDayStream({
    required String tripId,
    required String dayId,
  });

  Stream<Trip?> getTripByIdStream(String tripId);

  Future<void> updateTripBudgetId({
    required String tripId,
    required String budgetId,
  });

  Future<void> removeTripBudgetId(String tripId);

  Future<String?> getTripBudgetId(String tripId);
}
