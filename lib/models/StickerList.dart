// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'Sticker.dart';

StickerList stickerListFromJson(String str) => StickerList.fromJson(json.decode(str));

String stickerListToJson(StickerList data) => json.encode(data.toJson());

class StickerList {
  StickerList({
    this.stickers,
  });

  List<Sticker> stickers;

  factory StickerList.fromJson(Map<String, dynamic> json) => StickerList(
    stickers: List<Sticker>.from(json["stickers"].map((x) => Sticker.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "stickers": List<dynamic>.from(stickers.map((x) => x.toJson())),
  };
}
