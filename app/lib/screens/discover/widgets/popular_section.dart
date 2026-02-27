import 'package:anitrack/models/media_model.dart';
import 'package:anitrack/widgets/vertical_anime_card.dart';
import 'package:flutter/material.dart';

class PopularSection extends StatelessWidget {
  final MediaModel data;
  final String? detailRouteBasePath;
  const PopularSection({
    super.key,
    required this.data,
    this.detailRouteBasePath,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 220),
      child: data.media != null
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.media!.length,
              itemBuilder: (context, index) {
                final media = data.media![index];
                return VerticalAnimeCard(
                  media: media,
                  detailRouteBasePath: detailRouteBasePath,
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

