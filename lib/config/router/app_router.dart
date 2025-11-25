import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/genres_response.dart';
import 'package:flutter_e04_cinemapedia/presentation/screens/screens.dart';
import 'package:flutter_e04_cinemapedia/presentation/widgets/auth/auth_wrapper.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Ruta principal que usa AuthWrapper (maneja autenticación automáticamente)
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const AuthWrapper(),
    ),
    // Rutas de autenticación
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: SignupScreen.name, 
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: ForgotPasswordScreen.name,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    // Rutas protegidas de películas
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
      builder: (context, state) => const CategoriesScreen(),
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
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);