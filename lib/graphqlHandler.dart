import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'localStorageHandler.dart';
import 'locator.dart';

class GraphQLHandler {
  HttpLink _httpLink;
  GraphQLClient _client;

  String _token = "";

  var _localStorageHandler = locator<LocalStorageHandler>();

  static const String devUrl = 'https://silas-approved-dev.herokuapp.com/graphql';
  static const String prodUrl = 'https://silas-approved.herokuapp.com/graphql';


  // instance for singleton
  static final GraphQLHandler _instance = GraphQLHandler._privateConstructor();

  factory GraphQLHandler() {
    return _instance;
  }

  // actual (private) constructor
  GraphQLHandler._privateConstructor() {
    _setup();
  }

  _setup() async {

    _token = _localStorageHandler.token;

    if (_token != null && _token.isNotEmpty) {
      this._httpLink = HttpLink(
          kReleaseMode ? prodUrl : devUrl,
          defaultHeaders: <String, String>{
            'Authorization': 'Bearer $_token',
          });
    } else {
      this._httpLink = HttpLink(
        kReleaseMode ? prodUrl : devUrl,
      );
    }

    this._client = GraphQLClient(
        link: this._httpLink, cache: GraphQLCache(store: InMemoryStore()));
  }

  Future<bool> postSticker(
      {BuildContext context,
      String name,
      double lat,
      double lng,
      File stickerImage}) async {
    const postMutation = r"""
      mutation ($name: String!, $lat: Float!, $lng: Float!, $image: Upload!) { 
        post(name: $name, lat: $lat, lng: $lng,image: $image) { name imageUrl } 
      }
      """;

    var multipartFile = MultipartFile.fromBytes(
      'photo',
      stickerImage.readAsBytesSync(),
      filename: '${DateTime.now().second}.jpg',
      contentType: MediaType("image", "jpg"),
    );

    var opts = MutationOptions(
      document: gql(postMutation),
      variables: {
        "name": name,
        "lat": lat,
        "lng": lng,
        "image": multipartFile,
      },
    );

    var results = await _client.mutate(opts);
    debugPrint(results.toString());

    return !results.hasException;
  }

  Future<List> getCollectedStickerList() async {
    String allStickersQuery = """
      query collectedStickers() {
        collectedStickers {
          name
        }
      }
      """;

    var opts = QueryOptions(document: gql(allStickersQuery));
    var results = await _client.query(opts);
    debugPrint("RESULT");
    debugPrint(results.toString());
    if (!results.hasException) {
      var collectedStickers = results.data['collectedStickers'];
      var stickerNameList = [];
      collectedStickers.forEach((sticker) => stickerNameList.add(sticker['name']));
      return stickerNameList.cast<String>();
    } else {
      return const <String>[];
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    const loginMutation = r"""
      mutation ($email: String!, $password: String!) { 
        login(email: $email, password: $password) {
          token
          user {
            name
            email
          }
        }
      }
    """;

    var opts = MutationOptions(
      document: gql(loginMutation),
      variables: {"email": email, "password": password},
    );

    var results = await _client.mutate(opts);
    debugPrint("LOGIN RESULTS" + results.toString());

    if (!results.hasException) {
      var data = results.data['login'];
      debugPrint("Data" + data.toString());
      debugPrint("Token" + data['token']);
      _token = data['token'];
      _localStorageHandler.token =  _token;

      return data['user'];
    } else {
      return const {};
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String password, String name) async {
    const loginMutation = r"""
      mutation ($email: String!, $password: String!, $name: String!) { 
        signup(email: $email, password: $password, name: $name) {
          token
          user {
            name
            email
          }
        }
      }
    """;

    var opts = MutationOptions(
      document: gql(loginMutation),
      variables: {"email": email, "password": password, "name": name},
    );

    var results = await _client.mutate(opts);

    debugPrint(results.toString());

    if (!results.hasException) {
      var data = results.data['login'];
      _token = data['token'];
      _localStorageHandler.token =  _token;

      return data['user'];
    } else {
      return const {};
    }
  }

  Future<bool> scanSticker(String id) async {
    const loginMutation = r"""
      mutation ($stickerId: ID!) { 
        scan(stickerId: $stickerId) {
          name
          collectedStickers {
            name
          }
        }
      }
    """;

    var opts = MutationOptions(
      document: gql(loginMutation),
      variables: {"stickerId": int.parse(id)},
    );

    var result = await _client.mutate(opts);
    print(result.data.toString());

    return !result.hasException;
  }

  Future<List<dynamic>> getAllStickerLocations() async {
    String allStickersQuery = """
      query AllStickers() {
        stickers {
          id
          name
          location {
            lat
            lng
          }
          createdBy {
            name
          }
          imageUrl
        }
      }
    """;

    var opts = QueryOptions(document: gql(allStickersQuery));
    final stopwatch = Stopwatch()..start();
    var results = await _client.query(opts);
    print('doSomething() executed in ${stopwatch.elapsed}');


    debugPrint(results.toString());
    if (!results.hasException) {
      return results.data['stickers'];
    } else {
      return const [];
    }
  }
}
