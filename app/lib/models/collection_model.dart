// To parse this JSON data, do
//
//     final collectionModel = collectionModelFromJson(jsonString);

import 'dart:convert';

import 'package:anitrack/models/media_model.dart';

CollectionModel collectionModelFromJson(String str) =>
    CollectionModel.fromJson(json.decode(str));

String collectionModelToJson(CollectionModel data) =>
    json.encode(data.toJson());

// class CollectionModel {
//   Data? data;

//   CollectionModel({
//     this.data,
//   });

//   factory CollectionModel.fromJson(Map<String, dynamic> json) =>
//       CollectionModel(
//         data: json["data"] == null ? null : Data.fromJson(json["data"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "data": data?.toJson(),
//       };
// }

class CollectionModel {
  MediaListCollection? mediaListCollection;

  CollectionModel({
    this.mediaListCollection,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) =>
      CollectionModel(
        mediaListCollection: json["MediaListCollection"] == null
            ? null
            : MediaListCollection.fromJson(json["MediaListCollection"]),
      );

  Map<String, dynamic> toJson() => {
        "MediaListCollection": mediaListCollection?.toJson(),
      };
}

class MediaListCollection {
  List<ListElement>? lists;

  MediaListCollection({
    this.lists,
  });

  factory MediaListCollection.fromJson(Map<String, dynamic> json) =>
      MediaListCollection(
        lists: json["lists"] == null
            ? []
            : List<ListElement>.from(
                json["lists"]!.map((x) => ListElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "lists": lists == null
            ? []
            : List<dynamic>.from(lists!.map((x) => x.toJson())),
      };
}

class ListElement {
  List<Entry>? entries;

  ListElement({
    this.entries,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        entries: json["entries"] == null
            ? []
            : List<Entry>.from(json["entries"]!.map((x) => Entry.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "entries": entries == null
            ? []
            : List<dynamic>.from(entries!.map((x) => x.toJson())),
      };
}

class Entry {
  Media? media;
  int? progress;

  Entry({
    this.media,
    this.progress,
  });

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        media: json["media"] == null ? null : Media.fromJson(json["media"]),
        progress: json["progress"],
      );

  Map<String, dynamic> toJson() => {
        "media": media?.toJson(),
        "progress": progress,
      };
}

