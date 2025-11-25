import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_e04_cinemapedia/domain/repositories/favorites_repository.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/user_interactions/favorites_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final favoritesProvider = StateNotifierProvider<FavoriteNotifier, Set<String>>((
  ref,
) {
  final repo = ref.watch(favoritesRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser!;
  return FavoriteNotifier(repo, user.uid);
});

class FavoriteNotifier extends StateNotifier<Set<String>> {
  final FavoritesRepository repository;
  final String userId;

  FavoriteNotifier(this.repository, this.userId) : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    state = (await repository.getUserFavorites(userId)).toSet();
  }

  Future<void> toggle(String movieId) async {
    await repository.toggleFavorite(movieId, userId);

    if (state.contains(movieId)) {
      state = {...state}..remove(movieId);
    } else {
      state = {...state, movieId};
    }
  }
}
