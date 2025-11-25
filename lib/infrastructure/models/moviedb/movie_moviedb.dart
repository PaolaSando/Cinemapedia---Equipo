class MovieMovieDB {
  final bool adult;
  final String backdropPath;
  final List<int> genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String posterPath;
  final DateTime releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  MovieMovieDB({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory MovieMovieDB.fromJson(Map<String, dynamic> json) => MovieMovieDB(
        adult: json["adult"] ?? false,
        backdropPath: json["backdrop_path"] ?? '',
        genreIds: List<int>.from(json["genre_ids"].map((x) => x)),
        id: json["id"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"] ?? '',
        popularity: json["popularity"]?.toDouble() ?? 0.0,
        posterPath: json["poster_path"] ?? '',
        releaseDate: _parseDate(json["release_date"]),
        title: json["title"],
        video: json["video"] ?? false,
        voteAverage: json["vote_average"]?.toDouble() ?? 0.0,
        voteCount: json["vote_count"] ?? 0,
      );

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null || dateValue.toString().isEmpty) {
      return DateTime(1900);
    }

    try {
      return DateTime.parse(dateValue.toString());
    } catch (e) {
      // Si falla el parseo, intenta manejar formatos alternativos
      final dateString = dateValue.toString();

      // Verifica si tiene formato básico de fecha
      if (RegExp(r'^\d{4}-\d{1,2}-\d{1,2}').hasMatch(dateString)) {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          final year = int.tryParse(parts[0]) ?? 1900;
          final month = int.tryParse(parts[1]) ?? 1;
          final day = int.tryParse(parts[2]) ?? 1;

          // Valida rangos de fecha
          if (year >= 1900 &&
              month >= 1 &&
              month <= 12 &&
              day >= 1 &&
              day <= 31) {
            return DateTime(year, month, day);
          }
        }
      }

      // Si todo falla, retorna fecha por defecto
      return DateTime(1900);
    }
  }

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
        "id": id,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "release_date":
            "${releaseDate.year.toString().padLeft(4, '0')}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}",
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
      };
}
