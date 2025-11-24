import 'package:flutter_e04_cinemapedia/domain/entities/video.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/providers.dart';
import 'package:flutter_riverpod/legacy.dart';

final movieVideosProvider = StateNotifierProvider<MovieVideosNotifier, Map<String, List<Video>>>((ref) {
  final movieRepository = ref.watch(moviesRepositoryProvider);
  return MovieVideosNotifier(getMovieVideos: movieRepository.getMovieVideos);
});

typedef GetMovieVideosCallback = Future<List<Video>> Function(String movieId);

class MovieVideosNotifier extends StateNotifier<Map<String, List<Video>>> {
  final GetMovieVideosCallback getMovieVideos;

  MovieVideosNotifier({required this.getMovieVideos}) : super({});

  Future<void> loadMovieVideos(String movieId) async {
    if (state[movieId] != null) return;

    final videos = await getMovieVideos(movieId);
    state = {...state, movieId: videos};
  }
}