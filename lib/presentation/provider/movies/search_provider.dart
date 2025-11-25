import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_e04_cinemapedia/domain/repositories/movies_repository.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchTypeProvider = StateProvider<SearchType>((ref) => SearchType.movie);

enum SearchType { movie, actor }

final searchResultsProvider =
    StateNotifierProvider<SearchNotifier, List<Movie>>((ref) {
  final movieRepository = ref.watch(moviesRepositoryProvider);
  return SearchNotifier(movieRepository: movieRepository);
});

class SearchNotifier extends StateNotifier<List<Movie>> {
  final MoviesRepository movieRepository;

  SearchNotifier({required this.movieRepository}) : super([]);

  Future<void> search(String query, SearchType searchType) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    state = []; // Limpiar resultados anteriores

    try {
      List<Movie> results;

      if (searchType == SearchType.movie) {
        results = await movieRepository.searchMovies(query);
      } else {
        results = await movieRepository.searchMoviesByActor(query);
      }

      state = results;
    } catch (e) {
      state = []; // En caso de error, limpiar resultados
      rethrow;
    }
  }

  void clearResults() {
    state = [];
  }
}
