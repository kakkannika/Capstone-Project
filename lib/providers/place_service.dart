import 'package:flutter/foundation.dart';
import 'package:tourism_app/data/dummy_data/dummy_data.dart';
import 'package:tourism_app/models/place/place.dart';

class PlaceProvider with ChangeNotifier {
  List<Place> _places = [];

  List<Place> get places => _places;

  void fetchPlaces() {
    // Replace this with actual data fetching logic, e.g., from an API
    _places = dummyPlaces;
    notifyListeners();
  }
}
