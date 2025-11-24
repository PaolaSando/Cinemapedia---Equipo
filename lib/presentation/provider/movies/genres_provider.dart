import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/genres_response.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final genresProvider = FutureProvider<List<GenreModel>>((ref) async {
  final movieRepository = ref.watch(moviesRepositoryProvider);
  return await movieRepository.getGenres();
});

final moviesByGenreProvider =
    StateNotifierProvider<MoviesByGenreNotifier, List<Movie>>((ref) {
  return MoviesByGenreNotifier();
});

class MoviesByGenreNotifier extends StateNotifier<List<Movie>> {
  MoviesByGenreNotifier() : super([]);

  Future<void> loadMoviesByGenre(int genreId) async {
    // Aquí necesitarías inyectar el repository
    // Por simplicidad, lo manejaremos de otra forma
  }
}

// Provider para manejar películas por género con paginación
final genreMoviesProvider =
    StateNotifierProvider.family<GenreMoviesNotifier, List<Movie>, int>(
        (ref, genreId) {
  final movieRepository = ref.watch(moviesRepositoryProvider);
  return GenreMoviesNotifier(
    getMovies: ({int page = 1}) =>
        movieRepository.getMoviesByGenre(genreId, page: page),
  );
});

class GenreMoviesNotifier extends StateNotifier<List<Movie>> {
  int currentPage = 0;
  bool isLoading = false;
  final Future<List<Movie>> Function({int page}) getMovies;

  GenreMoviesNotifier({required this.getMovies}) : super([]);

  Future<void> loadNextPage() async {
    if (isLoading) return;
    isLoading = true;
    currentPage++;
    final List<Movie> movies = await getMovies(page: currentPage);
    state = [...state, ...movies];
    isLoading = false;
  }

  void clearMovies() {
    state = [];
    currentPage = 0;
  }
}
