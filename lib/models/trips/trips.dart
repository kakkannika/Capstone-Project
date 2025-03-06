// Trip Models
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/models/budget/budget.dart';
import 'package:tourism_app/models/trips/trip_days.dart';

class Trip {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripDay> days;
  final Budget budget;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.userId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.budget,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Trip(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      startDate: data['startDate'].toDate(),
      endDate: data['endDate'].toDate(),
      days: (data['days'] as List).map((d) => TripDay.fromMap(d)).toList(),
      budget: Budget.fromMap(data['budget']),
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'days': days.map((d) => d.toMap()).toList(),
      'budget': budget.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
