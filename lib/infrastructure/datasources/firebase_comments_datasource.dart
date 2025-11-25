import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_e04_cinemapedia/domain/datasources/comments_datasource.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/comment.dart';

class FirebaseCommentsDatasource implements CommentsDatasource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addComment(Comment comment) async {
    await firestore.collection('comments').add({
      'movieId': comment.movieId,
      'userId': comment.userId,
      'text': comment.text,
      'createdAt': comment.createdAt.toIso8601String(),
    });
  }

  @override
  Future<List<Comment>> getCommentsByMovie(String movieId) async {
    final query =
        await firestore
            .collection('comments')
            .where('movieId', isEqualTo: movieId)
            .orderBy('createdAt', descending: true)
            .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return Comment(
        id: doc.id,
        movieId: data['movieId'],
        userId: data['userId'],
        text: data['text'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    }).toList();
  }
}
