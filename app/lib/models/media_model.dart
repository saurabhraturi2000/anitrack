// To parse this JSON data, do
//
//     final mediaModel = mediaModelFromJson(jsonString);

import 'dart:convert';

// To parse this JSON data, do
//
//     final mediaModel = mediaModelFromJson(jsonString);

MediaModel mediaModelFromJson(String str) =>
    MediaModel.fromJson(json.decode(str));

String mediaModelToJson(MediaModel data) => json.encode(data.toJson());

class MediaModel {
  List<Media>? media;

  MediaModel({
    this.media,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) => MediaModel(
        media: json["media"] == null
            ? []
            : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
      };
}

class Media {
  int? id;
  Title? title;
  CoverImage? coverImage;
  String? bannerImage;
  String? format;
  int? duration;
  StartDate? startDate;
  int? episodes;
  int? averageScore;
  NextAiringEpisode? nextAiringEpisode;
  Status? status;

  Media({
    this.id,
    this.title,
    this.coverImage,
    this.bannerImage,
    this.format,
    this.duration,
    this.startDate,
    this.episodes,
    this.averageScore,
    this.nextAiringEpisode,
    this.status,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        id: json["id"],
        title: json["title"] == null ? null : Title.fromJson(json["title"]),
        coverImage: json["coverImage"] == null
            ? null
            : CoverImage.fromJson(json["coverImage"]),
        bannerImage: json["bannerImage"],
        format: json["format"],
        duration: json["duration"],
        startDate: json["startDate"] == null
            ? null
            : StartDate.fromJson(json["startDate"]),
        episodes: json["episodes"],
        averageScore: json["averageScore"],
        nextAiringEpisode: json["nextAiringEpisode"] == null
            ? null
            : NextAiringEpisode.fromJson(json["nextAiringEpisode"]),
        status:
            json["status"] == null ? null : statusValues.map[json["status"]],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title?.toJson(),
        "coverImage": coverImage?.toJson(),
        "bannerImage": bannerImage,
        "format": format,
        "duration": duration,
        "startDate": startDate?.toJson(),
        "episodes": episodes,
        "averageScore": averageScore,
        "nextAiringEpisode": nextAiringEpisode?.toJson(),
        "status": statusValues.reverse[status],
      };
}

class CoverImage {
  String? large;

  CoverImage({
    this.large,
  });

  factory CoverImage.fromJson(Map<String, dynamic> json) => CoverImage(
        large: json["large"],
      );

  Map<String, dynamic> toJson() => {
        "large": large,
      };
}

class StartDate {
  int? day;
  int? month;
  int? year;

  StartDate({
    this.day,
    this.month,
    this.year,
  });

  factory StartDate.fromJson(Map<String, dynamic> json) => StartDate(
        day: json["day"],
        month: json["month"],
        year: json["year"],
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "month": month,
        "year": year,
      };
}

class Title {
  String? english;
  String? romaji;

  Title({
    this.english,
    this.romaji,
  });

  factory Title.fromJson(Map<String, dynamic> json) => Title(
        english: json["english"],
        romaji: json["romaji"],
      );

  Map<String, dynamic> toJson() => {
        "english": english,
        "romaji": romaji,
      };
}

class NextAiringEpisode {
  int? episode;
  int? airingAt;

  NextAiringEpisode({
    this.episode,
    this.airingAt,
  });

  factory NextAiringEpisode.fromJson(Map<String, dynamic> json) =>
      NextAiringEpisode(
        episode: json["episode"],
        airingAt: json["airingAt"],
      );

  Map<String, dynamic> toJson() => {
        "episode": episode,
        "airingAt": airingAt,
      };
}

enum Status { FINISHED, RELEASING, NOT_YET_RELEASED, HIATUS, CANCELLED }

final statusValues = EnumValues({
  "FINISHED": Status.FINISHED,
  "RELEASING": Status.RELEASING,
  "NOT_YET_RELEASED": Status.NOT_YET_RELEASED,
  "HIATUS": Status.HIATUS,
  "CANCELLED": Status.CANCELLED,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
