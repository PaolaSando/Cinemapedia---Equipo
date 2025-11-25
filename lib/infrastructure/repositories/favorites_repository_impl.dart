import 'package:flutter_e04_cinemapedia/domain/datasources/favorites_datasource.dart';
import 'package:flutter_e04_cinemapedia/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesDatasource datasource;

  FavoritesRepositoryImpl(this.datasource);

  @override
  Future<List<String>> getUserFavorites(String userId) {
    return datasource.getUserFavorites(userId);
  }

  @override
  Future<bool> isFavorite(String movieId, String userId) {
    return datasource.isFavorite(movieId, userId);
  }

  @override
  Future<void> toggleFavorite(String movieId, String userId) {
    return datasource.toggleFavorite(movieId, userId);
  }
}
