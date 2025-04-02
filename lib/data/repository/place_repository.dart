import 'package:tourism_app/models/place/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> fetchAllPlaces();

  Future<Place?> getPlaceById(String placeId);

  Future<List<Place>> fetchPlacesByCategory(String category,String province);

  Future<List<Place>> fetchHightlyRatedPlaces(double minRating,String province);

  Future<List<Place>> searchPlaces(String query);
  
  Future<List<Place>> fetchPlacesByProvince(String province);
  
  
}
