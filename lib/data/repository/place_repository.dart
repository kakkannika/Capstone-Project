import 'package:tourism_app/models/place/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> fetchAllPlaces();

  Future<Place?> getPlaceById(String placeId);

  Future<List<Place>> fetchPlacesByCategory(String category);

  Future<List<Place>> fetchHightlyRatedPlaces(double minRating);

  Future<List<Place>> searchPlaces(String query);
  Future<List<Place>> fetchPlacesByProvince(String province);
  
}
