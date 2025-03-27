import 'package:tourism_app/models/place/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> fetchAllPlaces();

  Future<Place?> getPlaceById(String placeId);



  Future<List<Place>> searchPlaces(String query);
  
  
}
