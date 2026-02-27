import 'package:anilist_client/models/media_model.dart';
import 'package:anilist_client/widgets/vertical_anime_card.dart';
import 'package:flutter/material.dart';

class PopularSection extends StatelessWidget {
  final MediaModel data;
  const PopularSection({super.key, required this.data});

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
                return VerticalAnimeCard(media: media);
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
