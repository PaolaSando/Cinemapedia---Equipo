import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_e04_cinemapedia/domain/repositories/favorites_repository.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/datasources/firebase_favorites_datasource.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/repositories/favorites_repository_impl.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(FirebaseFavoritesDatasource());
});
