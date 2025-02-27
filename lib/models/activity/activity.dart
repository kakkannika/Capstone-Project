class Activity {
  String activityId;
  String itineraryId;
  String destinationId;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  bool isPlanned;

  Activity({
    required this.activityId,
    required this.itineraryId,
    required this.destinationId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isPlanned = true,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activityId'] ?? '',
      itineraryId: json['itineraryId'] ?? '',
      destinationId: json['destinationId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      isPlanned: json['isPlanned'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'itineraryId': itineraryId,
      'destinationId': destinationId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isPlanned': isPlanned,
    };
  }
}
