import 'package:tourism_app/domain/models/place/place.dart';
import 'package:tourism_app/data/repository/place_repository.dart';

abstract class FavoriteRepository {
  PlaceRepository get places;
  Future<List<String>> loadFavorites(String userId);
  Future<void> saveFavorites(String userId, List<String> favoritePlaceIds);
  Future<List<Place>> fetchFavoritePlaces(List<String> favoritePlaceIds);
}
