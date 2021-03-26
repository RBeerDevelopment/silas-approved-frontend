import 'dart:convert';

Sticker stickerFromJson(String str) => Sticker.fromJson(json.decode(str));

String stickerListToJson(Sticker data) => json.encode(data.toJson());

class Sticker {
  Sticker({
    this.id,
    this.name,
    this.location,
    this.createdBy,
    this.imageUrl,
  });

  String id;
  String name;
  Location location;
  CreatedBy createdBy;
  String imageUrl;

  factory Sticker.fromJson(Map<String, dynamic> json) => Sticker(
    id: json["id"],
    name: json["name"],
    location: Location.fromJson(json["location"]),
    createdBy: CreatedBy.fromJson(json["createdBy"]),
    imageUrl: json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "location": location.toJson(),
    "createdBy": createdBy.toJson(),
    "imageUrl": imageUrl,
  };
}

class CreatedBy {
  CreatedBy({
    this.name,
  });

  String name;

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}

class Location {
  Location({
    this.lat,
    this.lng,
  });

  double lat;
  double lng;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
  };
}