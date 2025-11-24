import 'package:flutter/material.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/genres_provider.dart';
import 'package:flutter_e04_cinemapedia/presentation/screens/movies/movie_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/genres_response.dart';

class GenreMoviesScreen extends ConsumerStatefulWidget {
  static const name = 'genre_movies_screen';
  final GenreModel genre;

  const GenreMoviesScreen({super.key, required this.genre});

  @override
  ConsumerState<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends ConsumerState<GenreMoviesScreen> {
  bool _initialLoadCompleted = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    // Cargar películas iniciales después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialMovies();
    });
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreMovies();
      }
    });
  }

  void _loadInitialMovies() {
    final notifier = ref.read(genreMoviesProvider(widget.genre.id).notifier);
    notifier.clearMovies();
    notifier.loadNextPage().then((_) {
      setState(() {
        _initialLoadCompleted = true;
      });
    });
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await ref
          .read(genreMoviesProvider(widget.genre.id).notifier)
          .loadNextPage();
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = ref.watch(genreMoviesProvider(widget.genre.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.genre.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildBody(movies),
    );
  }

  Widget _buildBody(List<Movie> movies) {
    if (!_initialLoadCompleted) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movies.isEmpty) {
      return const Center(
        child: Text('No se encontraron películas en esta categoría'),
      );
    }

    return Column(
      children: [
        // Contador de películas
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Text(
            '${movies.length} títulos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columnas como en la imagen
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.6, // Relación aspecto para posters
            ),
            itemCount: movies.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < movies.length) {
                return _MovieGridItem(movie: movies[index]);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}

class _MovieGridItem extends StatelessWidget {
  final Movie movie;

  const _MovieGridItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieScreen(movieId: movie.id.toString()),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster de la película
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Icon(
                        Icons.movie_outlined,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          // Título de la película
          Text(
            movie.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          // Rating
          Row(
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: Colors.yellow.shade700,
              ),
              SizedBox(width: 4),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
