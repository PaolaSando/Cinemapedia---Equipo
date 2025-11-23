import 'package:flutter/material.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/cast.dart'; // NUEVO IMPORT
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_info_provider.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_cast_provider.dart'; // NUEVO IMPORT
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(movieCastProvider.notifier).loadMovieCast(widget.movieId); // NUEVO
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];
    final List<Cast> cast = ref.watch(movieCastProvider)[widget.movieId] ?? []; // NUEVO

    if (movie == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _MovieDetail(movie: movie, cast: cast), // ACTUALIZADO
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieDetail extends StatelessWidget {
  final Movie movie;
  final List<Cast> cast; // NUEVO

  const _MovieDetail({required this.movie, required this.cast}); // ACTUALIZADO

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: textStyle.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(movie.overview),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Chip(
                      label: Text(
                        gender,
                        style: TextStyle(color: Colors.black87),
                      ),
                      backgroundColor: Colors.blueGrey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )),
            ],
          ),
        ),

        // ✅ NUEVA SECCIÓN: LISTA DE ACTORES
        if (cast.isNotEmpty) _CastSection(cast: cast),
        
        SizedBox(height: 100),
      ],
    );
  }
}

// ✅ NUEVO WIDGET: Sección de actores
class _CastSection extends StatelessWidget {
  final List<Cast> cast;

  const _CastSection({required this.cast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reparto',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cast.length,
              itemBuilder: (context, index) {
                final actor = cast[index];
                return _CastCard(actor: actor);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ NUEVO WIDGET: Tarjeta de actor
class _CastCard extends StatelessWidget {
  final Cast actor;

  const _CastCard({required this.actor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Foto del actor
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: actor.profilePath != null
                ? FadeInImage(
                    placeholder: AssetImage('assets/loading.gif'),
                    image: NetworkImage(
                      'https://image.tmdb.org/t/p/w200${actor.profilePath}',
                    ),
                    height: 120,
                    width: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 120,
                    width: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.person, size: 40),
                  ),
          ),
          SizedBox(height: 8),
          // Nombre del actor
          Text(
            actor.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          // Personaje
          Text(
            actor.character,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CustomSliverAppBar extends StatelessWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      expandedHeight: size.height * 0.7,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        title: Text(
          movie.title,
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.start,
        ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(movie.posterPath, fit: BoxFit.cover),
            ),
            SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87, Colors.black],
                    stops: [0.0, 0.9, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}