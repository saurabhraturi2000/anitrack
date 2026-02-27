import 'package:anitrack/models/media_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerticalAnimeCard extends StatelessWidget {
  const VerticalAnimeCard({
    super.key,
    required this.media,
    this.detailRouteBasePath,
  });

  final Media media;
  final String? detailRouteBasePath;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: (detailRouteBasePath != null && media.id != null)
          ? () => context.push('$detailRouteBasePath/${media.id}')
          : null,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 140,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(media.coverImage!.large!),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            width: 150,
            child: Text(
              media.title!.english ?? media.title!.romaji!,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
