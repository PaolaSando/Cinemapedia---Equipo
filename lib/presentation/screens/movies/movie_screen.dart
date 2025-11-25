import 'package:flutter/material.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/cast.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/video.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_info_provider.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_cast_provider.dart';
import 'package:flutter_e04_cinemapedia/presentation/provider/movies/movie_videos_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
    ref.read(movieVideosProvider.notifier).loadMovieVideos(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];
    final List<Cast> cast = ref.watch(movieCastProvider)[widget.movieId] ?? [];
    final List<Video> videos = ref.watch(movieVideosProvider)[widget.movieId] ?? [];

    if (movie == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
                videos: videos,
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
  final List<Video> videos;

  const _MovieDetail({
    required this.movie,
    required this.cast,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información principal de la película
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: size.width * 0.3,
                      height: size.width * 0.45,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.movie_rounded, 
                          size: 40, 
                          color: colorScheme.onSurfaceVariant),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: textStyle.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded, 
                                  color: Colors.white, 
                                  size: 16),
                              SizedBox(width: 4),
                              Text(
                                '${movie.voteAverage.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, 
                                  size: 14, 
                                  color: colorScheme.primary),
                              SizedBox(width: 4),
                              Text(
                                '${movie.releaseDate.year}',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      movie.overview,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 8),

        // Categorías
        if (movie.genreIds.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.category_rounded, 
                          color: colorScheme.primary, 
                          size: 20),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Géneros',
                      style: textStyle.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: movie.genreIds.map((genre) => Chip(
                    label: Text(
                      genre,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    shape: StadiumBorder(),
                    side: BorderSide.none,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  )).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 28),
        ],

        // SECCIÓN: TRÁILER - SIEMPRE VISIBLE
        _TrailerSection(videos: videos),

        SizedBox(height: 28),

        // SECCIÓN: REPARTO
        if (cast.isNotEmpty) _CastSection(cast: cast),
        
        SizedBox(height: 30),
      ],
    );
  }
}

class _TrailerSection extends StatelessWidget {
  final List<Video> videos;

  const _TrailerSection({required this.videos});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.videocam_rounded, 
                    color: colorScheme.primary, 
                    size: 20),
              ),
              SizedBox(width: 8),
              Text(
                'Tráiler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Mismo componente siempre, con estado interno
          _TrailerCard(hasTrailer: videos.isNotEmpty, video: videos.isNotEmpty ? videos.first : null),
        ],
      ),
    );
  }
}

class _TrailerCard extends StatelessWidget {
  final bool hasTrailer;
  final Video? video;

  const _TrailerCard({required this.hasTrailer, this.video});

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: hasTrailer ? _buildTrailerWithVideo() : _buildNoTrailer(),
      ),
    );
  }

  Widget _buildTrailerWithVideo() {
    return GestureDetector(
      onTap: () => _launchYouTubeUrl(video!.youtubeUrl),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail
          Image.network(
            video!.youtubeThumbnail,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderContent();
            },
          ),
          
          // Overlay
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          // Botón de play
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          // Título del video
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              video!.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTrailer() {
    return Container(
      height: 200, // MISMA ALTURA que el trailer con video
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_off_rounded,
              size: 40,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Tráiler no disponible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Esta película no tiene tráiler\ndisponible en este momento',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off_rounded, size: 50, color: Colors.grey[500]),
          SizedBox(height: 12),
          Text(
            'Imagen no disponible',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchYouTubeUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}

class _CastSection extends StatelessWidget {
  final List<Cast> cast;

  const _CastSection({required this.cast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.people_rounded, 
                    color: Theme.of(context).colorScheme.primary, 
                    size: 20),
              ),
              SizedBox(width: 8),
              Text(
                'Reparto Principal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Carrete horizontal adaptativo
          _AdaptiveCastList(cast: cast),
        ],
      ),
    );
  }
}

class _AdaptiveCastList extends StatelessWidget {
  final List<Cast> cast;

  const _AdaptiveCastList({required this.cast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _calculateCastListHeight(cast, context), // Altura dinámica
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final actor = cast[index];
          return _AdaptiveCastCard(actor: actor);
        },
      ),
    );
  }

  double _calculateCastListHeight(List<Cast> cast, BuildContext context) {
    // Encuentra el actor con el nombre más largo
    double maxHeight = 0;
    for (final actor in cast) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: actor.name,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        maxLines: 2,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: 120); // Ancho máximo de tarjeta
      final nameHeight = textPainter.height;

      final characterPainter = TextPainter(
        text: TextSpan(
          text: actor.character,
          style: TextStyle(fontSize: 12),
        ),
        maxLines: 3,
        textDirection: TextDirection.ltr,
      );
      characterPainter.layout(maxWidth: 120);
      final characterHeight = characterPainter.height;

      final totalHeight = 140 + // altura de la imagen
                          12 + // espacio entre imagen y texto
                          nameHeight + 
                          4 + // espacio entre nombre y personaje
                          characterHeight +
                          12; // padding inferior

      if (totalHeight > maxHeight) {
        maxHeight = totalHeight;
      }
    }
    
    // Altura mínima por si acaso
    return maxHeight.clamp(180, 250);
  }
}

class _AdaptiveCastCard extends StatelessWidget {
  final Cast actor;

  const _AdaptiveCastCard({required this.actor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 150, // Ancho fijo para el carrete
      margin: EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Foto del actor
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: actor.profilePath != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w300${actor.profilePath}',
                      height: 140,
                      width: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholderActor();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderActor();
                      },
                    )
                  : _buildPlaceholderActor(),
            ),
          ),
          SizedBox(height: 12),
          
          // Información del actor - COMPLETAMENTE ADAPTATIVA
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre del actor - COMPLETO
                Text(
                  actor.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                // Personaje - COMPLETO
                Text(
                  actor.character,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderActor() {
    return Container(
      height: 140,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded, size: 40, color: Colors.grey[500]),
          SizedBox(height: 8),
          Text(
            'Sin foto',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      expandedHeight: size.height * 0.5,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          movie.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white, // ✅ SOLO ESTE CAMBIO - Letra blanca
          ),
        ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: Icon(Icons.movie_rounded, 
                        size: 60, 
                        color: Colors.grey[500]),
                  );
                },
              ),
            ),
            SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.5, 1.0],
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