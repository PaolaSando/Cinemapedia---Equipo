import 'package:flutter_e04_cinemapedia/domain/entities/comment.dart';

abstract class CommentsRepository {
  Future<void> addComment(Comment comment);
  Future<List<Comment>> getMovieComments(String movieId);
}
