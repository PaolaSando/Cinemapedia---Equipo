import 'package:flutter_e04_cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final moviesRepositoryProvider = Provider((ref) {
  return MovieRepositoryImpl(MoviedbDatasource());
});