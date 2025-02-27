class User {
  String userId;
  String name;
  String email;
  String profilePicture;
  List<String> savedItineraries;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.profilePicture,
    this.savedItineraries = const [],
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      savedItineraries: List<String>.from(json['savedItineraries'] ?? []),
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'savedItineraries': savedItineraries,
    };
  }
}
