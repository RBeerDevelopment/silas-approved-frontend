import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageHandler {

  static LocalStorageHandler _instance;
  static SharedPreferences _preferences;

  static const String TokenKey = 'token';
  static const String UserKey = 'user';

  static Future<LocalStorageHandler> getInstance() async {
    if(_instance == null) {
      _instance = LocalStorageHandler();
    }

    if(_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }

    return _instance;
  }


  String get token {
    return _getFromDisk(TokenKey);
  }

  set token(String t) {
    _saveStringToDisk(TokenKey, t);
  }

  set user(Map<String, dynamic> u) {
    _saveStringToDisk(UserKey, json.encode(u));
  }

  void removeUser() {
    remove(UserKey);
  }

  void removeToken() {
    remove(TokenKey);
  }

  void remove(String key) {
    _preferences.remove(key);
  }


  Map<String, dynamic> get user {
    var userJson = _getFromDisk(UserKey);
    if (userJson == null) return null;

    return json.decode(userJson);
  }

  dynamic _getFromDisk(String key) {
    var value = _preferences.get(key);
    print("LOGGING Getting $key from disk, value: $value");
    return value;
  }

  _saveStringToDisk(String key, String content) {
    print("LOGGING Writing $key to disk, value: $content");
    _preferences.setString(key, content);
  }

}