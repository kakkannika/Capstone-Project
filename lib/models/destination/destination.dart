class Destination {
  String destinationId;
  String name;
  String location;
  String description;
  String imageUrl;
  String category;

  Destination({
    required this.destinationId,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      destinationId: json['destinationId'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destinationId': destinationId,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
