import 'package:flutter_e04_cinemapedia/domain/entities/video.dart';

class MovieDbVideosResponse {
  final int id;
  final List<Video> results;

  MovieDbVideosResponse({
    required this.id,
    required this.results,
  });

  factory MovieDbVideosResponse.fromJson(Map<String, dynamic> json) =>
      MovieDbVideosResponse(
        id: json["id"],
        results:
            List<Video>.from(json["results"].map((x) => Video.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}
