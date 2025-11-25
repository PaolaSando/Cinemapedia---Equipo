abstract class FavoritesRepository {
  Future<void> toggleFavorite(String movieId, String userId);
  Future<bool> isFavorite(String movieId, String userId);
  Future<List<String>> getUserFavorites(String userId);
}
