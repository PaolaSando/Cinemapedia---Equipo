import 'package:flutter_e04_cinemapedia/domain/entities/cast.dart';

class MovieDbCreditsResponse {
  final int id;
  final List<Cast> cast;
  final List<dynamic> crew;

  MovieDbCreditsResponse({
    required this.id,
    required this.cast,
    required this.crew,
  });

  factory MovieDbCreditsResponse.fromJson(Map<String, dynamic> json) => MovieDbCreditsResponse(
        id: json["id"],
        cast: List<Cast>.from(json["cast"].map((x) => Cast.fromJson(x))),
        crew: List<dynamic>.from(json["crew"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cast": List<dynamic>.from(cast.map((x) => x.toJson())),
        "crew": List<dynamic>.from(crew.map((x) => x)),
      };
}