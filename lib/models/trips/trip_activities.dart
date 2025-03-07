
enum ActivityType { visit, meal, transport, checkin, custom }

class Activity {
  final String id;
  final ActivityType type;
  final String? placeId;
  final String? customName;
  final String? notes;
  final DateTime? time;
  final double? cost;
  final String? location;

  Activity({
    required this.id,
    required this.type,
    this.placeId,
    this.customName,
    this.notes,
    this.time,
    this.cost,
    this.location,
  });

  String get displayName {
    return customName ?? placeId ?? 'Activity';
  }

  factory Activity.fromMap(Map data) {
    return Activity(
      id: data['id'],
      type: ActivityType.values[data['type']],
      placeId: data['placeId'],
      customName: data['customName'],
      notes: data['notes'],
      time: data['time']?.toDate(),
      cost: data['cost']?.toDouble(),
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'placeId': placeId,
      'customName': customName,
      'notes': notes,
      'time': time,
      'cost': cost,
      'location': location,
    };
  }
}
