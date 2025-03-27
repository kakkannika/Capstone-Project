import 'package:tourism_app/data/dummy_data/dummy_data.dart';
import 'package:tourism_app/data/repository/place_repository.dart';
import 'package:tourism_app/models/place/place.dart';

class PlaceMockRepository implements PlaceRepository {
  final List<Place> _places = dummyPlaces;
  @override
  Future<List<Place>> fetchAllPlaces() async {
    return Future.delayed(Duration(seconds: 1), () {
      return _places;
    });
  }

  @override
  Future<List<Place>> fetchHightlyRatedPlaces(double minRating) async {
    return Future.delayed(Duration(seconds: 1), () {
      return _places
          .where((place) => place.averageRating >= minRating)
          .toList();
    });
  }

  @override
  Future<List<Place>> fetchPlacesByCategory(String category) async {
    return Future.delayed(Duration(seconds: 1), () {
      return _places.where((place) => place.category == category).toList();
    });
  }

  @override
  Future<List<Place>> fetchPlacesByProvince(String province) async {
    return Future.delayed(Duration(seconds: 1), () {
      return _places.where((place) => place.province == province).toList();
    });
  }

  @override
  Future<Place?> getPlaceById(String placeId) async {
    return Future.delayed(Duration(seconds: 1), () {
      return _places.firstWhere((place) => place.id == placeId);
    });
  }

  @override
  Future<List<Place>> searchPlaces(String query) async {
    return Future.delayed(Duration(seconds: 1), () {
      return _places
          .where(
              (place) => place.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

}
