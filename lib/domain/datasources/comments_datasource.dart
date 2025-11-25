import 'package:flutter_e04_cinemapedia/domain/entities/comment.dart';

abstract class CommentsDatasource {
  Future<void> addComment(Comment comment);
  Future<List<Comment>> getCommentsByMovie(String movieId);
}
