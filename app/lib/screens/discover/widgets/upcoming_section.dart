import 'package:anitrack/models/media_model.dart';
import 'package:anitrack/widgets/vertical_anime_card.dart';
import 'package:flutter/material.dart';

class UpcomingSection extends StatefulWidget {
  final MediaModel data;
  const UpcomingSection({super.key, required this.data});

  @override
  State<UpcomingSection> createState() => _UpcomingSectionState();
}

class _UpcomingSectionState extends State<UpcomingSection> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 220),
      child: widget.data.media == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.data.media!.length,
              itemBuilder: (context, index) {
                final media = widget.data.media![index];
                return VerticalAnimeCard(media: media);
              },
            ),
    );
  }
}

