import 'package:flutter/material.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/genres_response.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/genres_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends StatelessWidget {
  static const name = 'categories_screen';

  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            // Regresa a la página principal
            context.go('/');
          },
        ),
      ),
      body: _CategoriesView(),
    );
  }
}

class _CategoriesView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(genresProvider);

    return genresAsync.when(
      data: (genres) {
        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            return _GenreCard(genre: genre);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error al cargar categorías'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(genresProvider);
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreCard extends ConsumerWidget {
  final GenreModel genre;

  const _GenreCard({required this.genre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navegación usando go_router
          context.push('/genre/${genre.id}', extra: genre);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 33, 70, 107),
                const Color.fromARGB(255, 174, 48, 138)
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              genre.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
