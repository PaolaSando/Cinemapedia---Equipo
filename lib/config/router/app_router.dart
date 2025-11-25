import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/genres_response.dart';
import 'package:flutter_e04_cinemapedia/presentation/screens/movies/search_screen.dart';
import 'package:flutter_e04_cinemapedia/presentation/screens/movies/categories_screen.dart';
import 'package:flutter_e04_cinemapedia/presentation/screens/movies/genre_movies_screen.dart';
import 'package:flutter_e04_cinemapedia/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/movie/:id',
      name: MovieScreen.name,
      builder: (context, state) {
        final movieId = state.pathParameters['id'] ?? 'no-id';
        return MovieScreen(movieId: movieId);
      },
    ),
    GoRoute(
      path: '/categories',
      name: CategoriesScreen.name,
      builder: (context, state) => CategoriesScreen(),
    ),
    GoRoute(
      path: '/genre/:id',
      name: GenreMoviesScreen.name,
      builder: (context, state) {
        final genre = state.extra as GenreModel;
        return GenreMoviesScreen(genre: genre);
      },
    ),
    GoRoute(
      path: '/search',
      name: SearchScreen.name,
      builder: (context, state) => SearchScreen(),
    ),
  ],
);
