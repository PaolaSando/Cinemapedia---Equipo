import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_e04_cinemapedia/presentation/provider/user_interactions/favorites_provider.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_info_provider.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final favoriteIds = ref.read(favoritesProvider);
    for (final id in favoriteIds) {
      final movie = ref.read(movieInfoProvider)[id];
      if (movie == null) {
        ref.read(movieInfoProvider.notifier).loadMovie(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = ref.watch(favoritesProvider).toList();
    final moviesMap = ref.watch(movieInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // 🔙 Volver
        ),
      ),

      body:
          favoriteIds.isEmpty
              ? const Center(
                child: Text(
                  "No tienes películas favoritas aún",
                  style: TextStyle(fontSize: 18),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.64,
                ),
                itemCount: favoriteIds.length,
                itemBuilder: (context, index) {
                  final id = favoriteIds[index];
                  final Movie? movie = moviesMap[id];

                  return GestureDetector(
                    onTap: () => context.push('/movie/$id'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child:
                                  movie == null
                                      ? Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                      : Image.network(
                                        movie.posterPath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, err, st) => Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.movie,
                                                size: 48,
                                              ),
                                            ),
                                      ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    movie?.title ?? 'Cargando...',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(favoritesProvider.notifier)
                                        .toggle(id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
