import 'dart:io';
import 'package:flutter/material.dart' as ui;
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

  GraphQLHandler() {
    _setup();
  }

  _setup() async {
    await _setupPrefs();

    if(_prefs.containsKey(_prefsTokenKey)) {
      this._token = _prefs.getString(_prefsTokenKey);
    }

    if(_token.isNotEmpty) {
      this._httpLink = HttpLink(
          'https://silas-approved-dev.herokuapp.com/graphql',
          defaultHeaders: <String, String>{
            'Authorization': 'Bearer $_token',
          }
      );
    } else {
      this._httpLink = HttpLink(
        'https://silas-approved-dev.herokuapp.com/graphql',
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
      {ui.BuildContext context,
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
    ui.debugPrint(results.toString());

    return true;
  }

  Future<Null> login(String email, String password) async {
    const loginMutation = r"""
      mutation ($email: String!, $password: String!) { 
        signup(email: $email, password: $password) {
          token
        }
      }
    """;

    var opts = MutationOptions(
      document: gql(loginMutation),
      variables: {"email": email, "password": password},
    );

    var results = await _client.mutate(opts);

    if(!results.hasException) {
      _token = results.data['login']['token'];
      _prefs.setString(_prefsTokenKey, _token);
    }

  }

  Future<Null> signUp(String email, String password, String name) async {
    const loginMutation = r"""
      mutation ($email: String!, $password: String!, $name: String!) { 
        signup(email: $email, password: $password, name: $name) {
          token
        }
      }
    """;

    var opts = MutationOptions(
      document: gql(loginMutation),
      variables: {"email": email, "password": password, "name": name},
    );

    var results = await _client.mutate(opts);

    ui.debugPrint(results.toString());

    if(!results.hasException) {
      _token = results.data['signup']['token'];
      _prefs.setString(_prefsTokenKey, _token);
    }

    ui.debugPrint(results.toString());
  }

  Future<List<dynamic>> getAllStickerLocations() async {
    String allStickersQuery = """
      query AllStickers() {
        stickers {
          id
          name
          createdBy {
            name
          }
          location {
            lat
            lng
          }
          imageUrl
        }
      }
    """;

    var opts = QueryOptions(document: gql(allStickersQuery));
    var results = await _client.query(opts);
    ui.debugPrint(results.toString());
    if (!results.hasException) {
      return results.data['stickers'];
    } else {
      throw Exception('error fetching data');
    }
  }
}
