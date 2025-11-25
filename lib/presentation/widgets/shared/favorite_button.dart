import 'package:flutter/material.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/user_interactions/favorites_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteButton extends ConsumerWidget {
  final String movieId;

  const FavoriteButton({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(movieId);

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFavorite ? Colors.red : Colors.white,
        size: 28,
      ),
      onPressed: () {
        ref.read(favoritesProvider.notifier).toggle(movieId);
      },
    );
  }
}
