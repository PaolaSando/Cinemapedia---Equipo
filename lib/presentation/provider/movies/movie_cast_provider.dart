import 'package:flutter_e04_cinemapedia/domain/entities/cast.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/providers.dart';
import 'package:flutter_riverpod/legacy.dart';

final movieCastProvider = StateNotifierProvider<MovieCastNotifier, Map<String, List<Cast>>>((ref) {
  final movieRepository = ref.watch(moviesRepositoryProvider);
  return MovieCastNotifier(getMovieCast: movieRepository.getMovieCast);
});

typedef GetMovieCastCallback = Future<List<Cast>> Function(String movieId);

class MovieCastNotifier extends StateNotifier<Map<String, List<Cast>>> {
  final GetMovieCastCallback getMovieCast;

  MovieCastNotifier({required this.getMovieCast}) : super({});

  Future<void> loadMovieCast(String movieId) async {
    if (state[movieId] != null) return; // Ya está cargado

    final cast = await getMovieCast(movieId);
    state = {...state, movieId: cast};
  }
}