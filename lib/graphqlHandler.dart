import 'dart:io';
import 'package:flutter/material.dart' as ui;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLHandler {
  static Future<bool> postSticker(
      {ui.BuildContext context,
      String name,
      double lat,
      double lng,
      String creatorName,
      File stickerImage}) async {
    const postMutation = r"""
      mutation ($name: String!, $lat: Float!, $lng: Float!, $creatorName: String! $image: Upload!) { 
        post(name: $name, lat: $lat, lng: $lng, creatorName: $creatorName, image: $image) { name imageUrl } 
      }
      """;

    ui.debugPrint('postSticker called');
    ui.debugPrint(stickerImage.path);

    final bytes = stickerImage.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;

    ui.debugPrint(mb.toString());

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
        "creatorName": creatorName,
        "image": multipartFile,
      },
    );

    final httpLink = HttpLink('https://silas-approved.herokuapp.com/graphql');

    var client = GraphQLClient(
        link: httpLink, cache: GraphQLCache(store: InMemoryStore()));

    var results = await client.mutate(opts);

    ui.debugPrint(results.toString());

    var message = results.hasException
        ? '${results.exception.graphqlErrors.join(',')}'
        : "Image was uploaded successfully!";

    final snackBar = ui.SnackBar(content: ui.Text(message));
    ui.Scaffold.of(context).showSnackBar(snackBar);

    return true;
  }

  static Future<List<dynamic>> getAllStickerLocations(resultHandler) async {
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

    final httpLink = HttpLink('https://silas-approved.herokuapp.com/graphql');

    var client = GraphQLClient(
        link: httpLink, cache: GraphQLCache(store: InMemoryStore()));

    var opts = QueryOptions(document: gql(allStickersQuery));
    var results = await client.query(opts);
    if(!results.hasException) {
      return results.data['stickers'];
    } else {
      throw Exception('error fetching data');
    }


  }
}
