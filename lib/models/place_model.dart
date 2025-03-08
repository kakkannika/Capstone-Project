enum PlaceCategory { temple, museum, restaurant, park, market, hotel, other }

class GeoPoint {
  final double latitude;
  final double longitude;
  
  GeoPoint(this.latitude, this.longitude);
  
  factory GeoPoint.fromString(String locationString) {
    try {
      final coordinates = locationString.split(',');
      return GeoPoint(
        double.parse(coordinates[0].trim()),
        double.parse(coordinates[1].trim()),
      );
    } catch (e) {
      print('Error parsing location string: $locationString');
      print('Error details: $e');
      // Return a default location if parsing fails
      return GeoPoint(0, 0);
    }
  }

  @override
  String toString() => '$latitude,$longitude';
}

class DocumentSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  
  DocumentSnapshot(this.id, this._data);
  
  Map<String, dynamic> data() => _data;
}

class Place {
  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final List<String> imageUrls;
  final PlaceCategory category;
  final double? entranceFee;
  final String? openingHours;
  final double? averageRating;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.imageUrls,
    required this.category,
    this.entranceFee,
    this.openingHours,
    this.averageRating,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    try {
      print('Converting document ${doc.id} to Place object');
      Map<String, dynamic> data = doc.data();
      print('Document data: $data');

      // Handle location
      GeoPoint location;
      if (data['location'] is String) {
        location = GeoPoint.fromString(data['location'] as String);
      } else {
        print('Warning: Invalid location format in document ${doc.id}');
        location = GeoPoint(0, 0);
      }

      // Handle image URLs
      List<String> imageUrls = [];
      if (data['imageURL'] != null) {
        print('Found single imageURL: ${data['imageURL']}');
        imageUrls.add(data['imageURL'] as String);
      } else if (data['imageUrls'] != null) {
        print('Found imageUrls array: ${data['imageUrls']}');
        imageUrls = List<String>.from(data['imageUrls']);
      } else {
        print('Warning: No image URLs found in document ${doc.id}');
      }

      // Handle category
      PlaceCategory category;
      try {
        category = PlaceCategory.values[data['category'] as int];
      } catch (e) {
        print('Warning: Invalid category in document ${doc.id}, defaulting to "other"');
        category = PlaceCategory.other;
      }

      return Place(
        id: doc.id,
        name: data['name'] as String? ?? 'Unnamed Place',
        description: data['description'] as String? ?? 'No description available',
        location: location,
        imageUrls: imageUrls,
        category: category,
        entranceFee: (data['entranceFee'] as num?)?.toDouble(),
        openingHours: data['openingHours'] as String?,
        averageRating: (data['averageRating'] as num?)?.toDouble(),
      );
    } catch (e, stackTrace) {
      print('Error creating Place from document ${doc.id}:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('Document data: ${doc.data()}');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location.toString(),
      'imageURL': imageUrls.isNotEmpty ? imageUrls[0] : null,
      'category': category.index,
      'entranceFee': entranceFee,
      'openingHours': openingHours,
      'averageRating': averageRating,
    };
  }

  @override
  String toString() {
    return 'Place{id: $id, name: $name, category: $category, imageUrls: $imageUrls}';
  }
}