import 'package:anilist_client/models/media_model.dart';
import 'package:flutter/material.dart';

class VerticalAnimeCard extends StatelessWidget {
  const VerticalAnimeCard({
    super.key,
    required this.media,
  });

  final Media media;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                width: 140,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      media.coverImage!.large!,
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // if (media.episodes != null)
              //   Positioned(
              //     top: 0,
              //     left: 8,
              //     child: Container(
              //       padding: EdgeInsets.all(3),
              //       decoration: BoxDecoration(
              //         color: Colors.black,
              //         borderRadius: BorderRadius.only(
              //           bottomRight: Radius.circular(6),
              //         ),
              //       ),
              //       child: Text(
              //         media.episodes.toString(),
              //         style: TextStyle(
              //           fontSize: 9,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // if (media.format != null)
              //   Positioned(
              //     top: 0,
              //     right: 8,
              //     child: Container(
              //       padding: EdgeInsets.all(3),
              //       decoration: BoxDecoration(
              //         color: Colors.black,
              //         borderRadius: BorderRadius.only(
              //           bottomLeft: Radius.circular(6),
              //         ),
              //       ),
              //       child: Text(
              //         media.format!,
              //         style: TextStyle(
              //           fontSize: 9,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // if (media.averageScore != null)
              //   Positioned(
              //     bottom: 0,
              //     left: 8,
              //     child: Container(
              //       padding: EdgeInsets.all(3),
              //       decoration: BoxDecoration(
              //         color: Colors.black,
              //         borderRadius: BorderRadius.only(
              //           topRight: Radius.circular(6),
              //         ),
              //       ),
              //       child: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Icon(
              //             Icons.star,
              //             color: Colors.yellow,
              //             size: 10,
              //           ),
              //           Text(
              //             (media.averageScore! / 10).toString(),
              //             style: TextStyle(
              //               fontSize: 9,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //   )
            ],
          ),
        ),
        // Image(
        //   image: NetworkImage(
        //     media.coverImage!.large!,
        //   ),
        // ),
        Container(
          padding: EdgeInsets.only(top: 8),
          width: 150,
          child: Text(
            media.title!.english ?? media.title!.romaji!,
            style: TextStyle(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Container(
        //   width: 200,
        //   decoration: BoxDecoration(
        //     image: DecorationImage(
        //       image: NetworkImage(
        //           media.coverImage!.large!),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        //   child: Text(
        //     media.title!.english!,
        //   ),
        // ),
      ],
    );
  }
}
