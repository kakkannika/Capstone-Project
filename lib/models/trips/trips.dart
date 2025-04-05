import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:tourism_app/models/trips/trip_days.dart';

class Trip {
  final String id;
  final String userId;
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;
  final List<Day> days;
  final String? budgetId;
  final String? province;

  Trip({
    required this.id,
    required this.userId,
    required this.tripName,
    required this.startDate,
    required this.endDate,
    required this.days,
    this.budgetId,
    this.province,
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
      budgetId: data['budgetId'] as String?,
      province: data['province'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tripName': tripName,
      'startDate': firestore.Timestamp.fromDate(startDate),
      'endDate': firestore.Timestamp.fromDate(endDate),
      'budgetId': budgetId,
      'province': province,
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

  // Check if the trip has a budget
  bool get hasBudget => budgetId != null && budgetId!.isNotEmpty;

  // Create a copy of this trip with updated fields
  Trip copyWith({
    String? id,
    String? userId,
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
    List<Day>? days,
    String? budgetId,
    String? province,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripName: tripName ?? this.tripName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
      budgetId: budgetId ?? this.budgetId,
      province: province ?? this.province,
    );
  }
}