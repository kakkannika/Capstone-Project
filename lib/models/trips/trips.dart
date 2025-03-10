import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:tourism_app/models/trips/trip_days.dart';

class Trip {
  final String id;
  final String userId;
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;
  final List<Day> days;

  Trip({
    required this.id,
    required this.userId,
    required this.tripName,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory Trip.fromFirestore(
    firestore.DocumentSnapshot<Map<String, dynamic>> doc,
    List<Day> days,
  ) {
    final data = doc.data()!;
    return Trip(
      id: doc.id,
      userId: data['userId'] as String,
      tripName: data['tripName'] as String,
      startDate: (data['startDate'] as firestore.Timestamp).toDate(),
      endDate: (data['endDate'] as firestore.Timestamp).toDate(),
      days: days,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tripName': tripName,
      'startDate': firestore.Timestamp.fromDate(startDate),
      'endDate': firestore.Timestamp.fromDate(endDate),
    };
  }

  // Get a specific day by its number
  Day? getDayByNumber(int dayNumber) {
    try {
      return days.firstWhere((day) => day.dayNumber == dayNumber);
    } catch (e) {
      return null;
    }
  }

  // Get number of days in the trip
  int get numberOfDays => days.length;

  // Check if a place exists in any day of the trip
  bool hasPlace(String placeId) {
    return days.any((day) => day.placeIds.contains(placeId));
  }

  // Get which day contains a specific place
  Day? getDayContainingPlace(String placeId) {
    try {
      return days.firstWhere((day) => day.placeIds.contains(placeId));
    } catch (e) {
      return null;
    }
  }
}