import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movies_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final movieSlideshowProvider = Provider<List<Movie>>((ref){
  final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);

  if(nowPlayingMovies.isEmpty){
    return [];
  }
  return nowPlayingMovies.sublist(0,6);
});
