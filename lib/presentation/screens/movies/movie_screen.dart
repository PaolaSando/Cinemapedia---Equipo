import 'package:flutter/material.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/cast.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/video.dart'; // NUEVO IMPORT
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_info_provider.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_cast_provider.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_videos_provider.dart'; // NUEVO IMPORT
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // NUEVO IMPORT

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
    ref.read(movieCastProvider.notifier).loadMovieCast(widget.movieId);
    ref.read(movieVideosProvider.notifier).loadMovieVideos(widget.movieId); // NUEVO
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];
    final List<Cast> cast = ref.watch(movieCastProvider)[widget.movieId] ?? [];
    final List<Video> videos = ref.watch(movieVideosProvider)[widget.movieId] ?? []; // NUEVO

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
              (context, index) => _MovieDetail(
                movie: movie, 
                cast: cast, 
                videos: videos // NUEVO
              ),
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
  final List<Cast> cast;
  final List<Video> videos; // NUEVO

  const _MovieDetail({
    required this.movie, 
    required this.cast, 
    required this.videos // NUEVO
  });

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

        // ✅ NUEVA SECCIÓN: TRÁILER
        if (videos.isNotEmpty) _TrailerSection(videos: videos),

        // ✅ SECCIÓN EXISTENTE: LISTA DE ACTORES
        if (cast.isNotEmpty) _CastSection(cast: cast),
        
        SizedBox(height: 100),
      ],
    );
  }
}

// ✅ NUEVO WIDGET: Sección del Tráiler
class _TrailerSection extends StatelessWidget {
  final List<Video> videos;

  const _TrailerSection({required this.videos});

  @override
  Widget build(BuildContext context) {
    final trailer = videos.first; // Tomar el primer trailer

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tráiler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () => _launchYouTubeUrl(trailer.youtubeUrl),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Thumbnail del video
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    trailer.youtubeThumbnail,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
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
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: Icon(Icons.videocam_off, size: 50),
                      );
                    },
                  ),
                ),
                // Botón de play
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            trailer.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (videos.length > 1) ...[
            SizedBox(height: 12),
            Text(
              'Más videos (${videos.length - 1})',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _launchYouTubeUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// ✅ WIDGET EXISTENTE: Sección de actores
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

// ✅ WIDGET EXISTENTE: Tarjeta de actor
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