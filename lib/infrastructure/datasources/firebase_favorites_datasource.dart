import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_e04_cinemapedia/domain/datasources/favorites_datasource.dart';

class FirebaseFavoritesDatasource implements FavoritesDatasource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<bool> isFavorite(String movieId, String userId) async {
    final query =
        await firestore
            .collection('favorites')
            .where('movieId', isEqualTo: movieId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

    return query.docs.isNotEmpty;
  }

  @override
  Future<void> toggleFavorite(String movieId, String userId) async {
    final query =
        await firestore
            .collection('favorites')
            .where('movieId', isEqualTo: movieId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      await firestore.collection('favorites').add({
        'movieId': movieId,
        'userId': userId,
      });
    } else {
      await query.docs.first.reference.delete();
    }
  }

  @override
  Future<List<String>> getUserFavorites(String userId) async {
    final query =
        await firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .get();

    return query.docs.map((e) => e['movieId'] as String).toList();
  }
}
