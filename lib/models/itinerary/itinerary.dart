class Itinerary {
  String itineraryId;
  String userId;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  List<String> destinations;
  List<String> activities;
  List<String> collaborators;

  Itinerary({
    required this.itineraryId,
    required this.userId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.destinations = const [],
    this.activities = const [],
    this.collaborators = const [],
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      itineraryId: json['itineraryId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      destinations: List<String>.from(json['destinations'] ?? []),
      activities: List<String>.from(json['activities'] ?? []),
      collaborators: List<String>.from(json['collaborators'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itineraryId': itineraryId,
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'destinations': destinations,
      'activities': activities,
      'collaborators': collaborators,
    };
  }
}
