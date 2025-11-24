import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_e04_cinemapedia/domain/entities/video.dart';

class MovieTrailerWidget extends StatelessWidget {
  final List<Video> videos;

  const MovieTrailerWidget({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return SizedBox(); // No mostrar nada si no hay trailers
    }

    final trailer = videos.first; // Tomar el primer trailer

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tráiler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () => _launchYouTubeUrl(trailer.youtubeUrl),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Thumbnail del video
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    trailer.youtubeThumbnail,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
                // Botón de play
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            trailer.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (videos.length > 1) ...[
            SizedBox(height: 12),
            Text(
              'Más videos (${videos.length - 1})',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _launchYouTubeUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}