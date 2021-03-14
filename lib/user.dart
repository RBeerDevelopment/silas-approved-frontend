import 'package:flutter/foundation.dart';
import 'localStorageHandler.dart';
import 'locator.dart';

class User extends ChangeNotifier {

  var localStoarageHandler = locator<LocalStorageHandler>();

  Map<String, dynamic> _user = {};

  Map<String, dynamic> getUser() {
    return localStoarageHandler.user;
  }

  void setUser(Map newUser) {
    _user = newUser;
    localStoarageHandler.user = _user;
    notifyListeners();
  }
}