class Comment {
  final String id;
  final String movieId;
  final String userId;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });
}
