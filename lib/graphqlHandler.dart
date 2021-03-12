import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLHandler {
  HttpLink _httpLink;
  GraphQLClient _client;

  SharedPreferences _prefs;
  String _token = "";
  String _prefsTokenKey = "graphqlToken";

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
    await _setupPrefs();

    if (_prefs.containsKey(_prefsTokenKey)) {
      this._token = _prefs.getString(_prefsTokenKey);
    }

    if (_token.isNotEmpty) {
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

  _setupPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey(_prefsTokenKey)) {
      _token = _prefs.getString(_prefsTokenKey);
    }
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

    return true;
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
    if (!results.hasException) {
      var collectedStickers = results.data['collectedStickers'];
      var stickerNameList = [];
      collectedStickers.forEach((sticker) => stickerNameList.add(sticker['name']));
      return stickerNameList.cast<String>();
    } else {
      throw Exception('error fetching data');
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
    debugPrint(results.toString());

    if (!results.hasException) {
      var data = results.data['login'];
      _token = data['token'];
      _prefs.setString(_prefsTokenKey, _token);

      return data['user'];
    } else {
      return null;
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
      _prefs.setString(_prefsTokenKey, _token);

      return data['user'];
    } else {
      return null;
    }
  }

  Future<Null> scanSticker(String id) async {
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

    var results = await _client.mutate(opts);

    debugPrint(results.toString());
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
      throw Exception('error fetching data');
    }
  }
}
