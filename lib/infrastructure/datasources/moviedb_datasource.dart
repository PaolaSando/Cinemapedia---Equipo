import 'package:dio/dio.dart';
import 'package:flutter_e04_cinemapedia/config/constants/environment.dart';
import 'package:flutter_e04_cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/cast.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/video.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/genres_response.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/movie_details.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/moviedb_credits_response.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/moviedb_videos_response.dart';

class MoviedbDatasource extends MoviesDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {
        'api_key': Environment.theMovieDbKey,
        'language': 'es-MX',
      },
    ),
  );

  List<Movie> _jsonToMovies(Map<String, dynamic> json) {
    final movieDBResponse = MovieDbResponse.fromJson(json);
    final List<Movie> movies =
        movieDBResponse.results
            .where((moviedb) => moviedb.posterPath != 'no-poster')
            .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
            .toList();
    return movies;
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response = await dio.get(
      '/movie/now_playing',
      queryParameters: {'page': page},
    );
    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    final response = await dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );
    return _jsonToMovies(response.data);
  }
  
  @override
  Future<List<Movie>> getTopRated({int page = 1}) async{
    final response = await dio.get(
      '/movie/top_rated',
      queryParameters: {'page': page},
    );
    return _jsonToMovies(response.data);
  }
  
  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async{
    final response = await dio.get(
      '/movie/upcoming',
      queryParameters: {'page': page},
    );
    return _jsonToMovies(response.data);
  }
  
  @override
  Future<Movie> getMovieById(String id) async{
    final response = await dio.get('/movie/$id');
    if(response.statusCode != 200) 
      throw Exception('Movie with id: $id not found');
    
    final movieDetails = MovieDetails.fromJson(response.data);

    final movie = MovieMapper.movieDetailsToEntity(movieDetails);

    return movie;
  }

  @override
Future<List<Cast>> getMovieCast(String movieId) async {
  final response = await dio.get('/movie/$movieId/credits');
  
  if (response.statusCode != 200) {
    throw Exception('Error loading cast for movie: $movieId');
  }
  
  final creditsResponse = MovieDbCreditsResponse.fromJson(response.data);
  
  // Filtrar solo los actores principales
  final mainCast = creditsResponse.cast
      .where((actor) => actor.order <= 10) // Primeros 10 actores
      .toList();
  
  return mainCast;
}
@override
Future<List<Video>> getMovieVideos(String movieId) async {
  final response = await dio.get('/movie/$movieId/videos');
  
  if (response.statusCode != 200) {
    throw Exception('Error loading videos for movie: $movieId');
  }
  
  final videosResponse = MovieDbVideosResponse.fromJson(response.data);
  
  // Filtrar solo trailers de YouTube
  final trailers = videosResponse.results
      .where((video) => video.site == 'YouTube' && video.type == 'Trailer')
      .toList();
  
  return trailers;
}
@override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final response = await dio.get(
      '/discover/movie',
      queryParameters: {
        'page': page,
        'with_genres': genreId,
      },
    );
    return _jsonToMovies(response.data);
  }

  @override
  Future<List<GenreModel>> getGenres() async {
    final response = await dio.get('/genre/movie/list');
    final genresResponse = GenresResponse.fromJson(response.data);
    return genresResponse.genres;
  }
}
