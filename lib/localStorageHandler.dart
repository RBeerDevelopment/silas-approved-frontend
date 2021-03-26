import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/User.dart';

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

  set user(User u) {
    if(u != null) {
      _saveStringToDisk(UserKey, userToJson(u));
    } else {
      removeUser();
    }

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


  User get user {
    var userJson = _getFromDisk(UserKey);
    if (userJson == null) return null;

    return userFromJson(userJson);
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