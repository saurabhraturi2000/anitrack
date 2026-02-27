import 'package:flutter/material.dart';
import 'package:anitrack/utils/app_colors.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    super.key,
    this.onCategorySelected,
  });

  final ValueChanged<String>? onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // final List<Map<String, dynamic>> chatGptGenres = [
    //   {"name": "Action", "icon": Icons.sports_kabaddi},
    //   {"name": "Adventure", "icon": Icons.explore},
    //   {"name": "Comedy", "icon": Icons.sentiment_very_satisfied},
    //   {"name": "Drama", "icon": Icons.theater_comedy},
    //   {"name": "Ecchi", "icon": Icons.favorite},
    //   {"name": "Fantasy", "icon": Icons.auto_awesome},
    //   {"name": "Hentai", "icon": Icons.visibility_off},
    //   {"name": "Horror", "icon": Icons.face}, // Requires Material 3 (Icons.ghost)
    //   {"name": "Mahou Shoujo", "icon": Icons.star},
    //   {"name": "Mecha", "icon": Icons.smart_toy},
    //   {"name": "Music", "icon": Icons.music_note},
    //   {"name": "Mystery", "icon": Icons.visibility},
    //   {"name": "Psychological", "icon": Icons.psychology},
    //   {"name": "Romance", "icon": Icons.favorite_border},
    //   {"name": "Sci-Fi", "icon": Icons.science},
    //   {"name": "Slice of Life", "icon": Icons.local_cafe},
    //   {"name": "Sports", "icon": Icons.sports_soccer},
    //   {"name": "Supernatural", "icon": Icons.bolt},
    //   {"name": "Thriller", "icon": Icons.movie_filter},
    // ];

    final Map<String, IconData> genres = {
      "Action": Icons.sports_kabaddi, //(Icons.swords)
      "Adventure": Icons.explore,
      "Comedy": Icons.emoji_emotions,
      "Drama": Icons.theater_comedy,
      "Ecchi": Icons.heart_broken, // Consider a more appropriate icon if needed
      "Fantasy": Icons.castle,
      "Hentai": Icons
          .warning, //  Consider a more appropriate icon or none at all due to sensitive nature.
      "Horror": Icons.masks,
      "Mahou Shoujo": Icons.stars,
      "Mecha": Icons.android,
      "Music": Icons.music_note,
      "Mystery": Icons.question_mark,
      "Psychological": Icons.psychology,
      "Romance": Icons.favorite,
      "Sci-Fi": Icons.rocket,
      "Slice of Life": Icons.home,
      "Sports": Icons.fitness_center,
      "Supernatural": Icons.bolt,
      "Thriller": Icons.local_police,
    };

    // final List<Map<String, dynamic>> genres = [
    //   {"name": "Action", "icon": Icons.flash_on},
    //   {"name": "Adventure", "icon": Icons.explore},
    //   {"name": "Comedy", "icon": Icons.sentiment_very_satisfied},
    //   {"name": "Drama", "icon": Icons.theater_comedy},
    //   {"name": "Ecchi", "icon": Icons.favorite},
    //   {"name": "Fantasy", "icon": Icons.star},
    //   {"name": "Hentai", "icon": Icons.visibility_off},
    //   {"name": "Horror", "icon": Icons.face},
    //   {"name": "Mahou Shoujo", "icon": Icons.star},
    //   {"name": "Mecha", "icon": Icons.smart_toy},
    //   {"name": "Music", "icon": Icons.music_note},
    //   {"name": "Mystery", "icon": Icons.question_answer},
    //   {"name": "Psychological", "icon": Icons.psychology},
    //   {"name": "Romance", "icon": Icons.favorite_border},
    //   {"name": "Sci-Fi", "icon": Icons.science},
    //   {"name": "Slice of Life", "icon": Icons.living},
    //   {"name": "Sports", "icon": Icons.sports},
    //   {"name": "Supernatural", "icon": Icons.visibility},
    //   {"name": "Thriller", "icon": Icons.local_movies},
    // ];

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SingleChildScrollView(
        // Enables horizontal scrolling if needed
        scrollDirection: Axis.horizontal,
        child: Row(
          children: genres.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onCategorySelected?.call(entry.key),
                child: Chip(
                  backgroundColor: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: colors.divider),
                  ),
                  avatar: Icon(entry.value, color: colors.accent, size: 18),
                  label: Text(
                    entry.key,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

