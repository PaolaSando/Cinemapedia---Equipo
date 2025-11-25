import 'package:flutter_e04_cinemapedia/domain/entities/cast.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/movies.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/video.dart';
import 'package:flutter_e04_cinemapedia/infrastructure/models/moviedb/genres_response.dart';

abstract class MoviesRepository {
  Future<List<Movie>> getNowPlaying({int page = 1});

  Future<List<Movie>> getPopular({int page = 1});

  Future<List<Movie>> getTopRated({int page = 1});

  Future<List<Movie>> getUpcoming({int page = 1});

  Future<Movie> getMovieById(String id);

  Future<List<Cast>> getMovieCast(String movieId);

  Future<List<Video>> getMovieVideos(String movieId);

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1});
  
  Future<List<GenreModel>> getGenres();

  Future<List<Movie>> searchMovies(String query);
  
  Future<List<Movie>> searchMoviesByActor(String actorName);
}