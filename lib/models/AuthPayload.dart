import 'dart:convert';

import 'User.dart';

AuthPayload authPayloadFromJson(String str) => AuthPayload.fromJson(json.decode(str));

String authPayloadToJson(AuthPayload data) => json.encode(data.toJson());

class AuthPayload {
  AuthPayload({
    this.token,
    this.user,
  });

  String token;
  User user;

  factory AuthPayload.fromJson(Map<String, dynamic> json) => AuthPayload(
    token: json["token"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "user": user.toJson(),
  };
}