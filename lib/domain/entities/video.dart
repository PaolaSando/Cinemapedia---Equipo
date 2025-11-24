class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;
  final DateTime publishedAt;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
    required this.publishedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json["id"],
        key: json["key"],
        name: json["name"],
        site: json["site"],
        type: json["type"],
        official: json["official"],
        publishedAt: DateTime.parse(json["published_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "name": name,
        "site": site,
        "type": type,
        "official": official,
        "published_at": publishedAt.toIso8601String(),
      };

  // URL para YouTube
  String get youtubeUrl => "https://www.youtube.com/watch?v=$key";
  
  // URL para embed
  String get youtubeEmbedUrl => "https://www.youtube.com/embed/$key";
  
  // Thumbnail de YouTube
  String get youtubeThumbnail => "https://img.youtube.com/vi/$key/0.jpg";
}