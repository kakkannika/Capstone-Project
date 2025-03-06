import 'package:tourism_app/models/trips/trip_activities.dart';

class TripDay {
  final int dayNumber;
  final List<Activity> activities;
  final double dailyBudget;

  TripDay({
    required this.dayNumber,
    required this.activities,
    this.dailyBudget = 0.0,
  });

  double get dayTotalCost => activities.fold(
    0, 
    (sum, activity) => sum + (activity.cost ?? 0)
  );

  factory TripDay.fromMap(Map data) {
    return TripDay(
      dayNumber: data['dayNumber'],
      dailyBudget: data['dailyBudget']?.toDouble() ?? 0.0,
      activities: (data['activities'] as List)
          .map((a) => Activity.fromMap(a))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'dailyBudget': dailyBudget,
      'activities': activities.map((a) => a.toMap()).toList(),
    };
  }
}
