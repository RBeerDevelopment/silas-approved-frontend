import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'localStorageHandler.dart';
import 'models/User.dart';

GetIt locator = GetIt.instance;

Future setupLocator() async {
  var localStorageHandler = await LocalStorageHandler.getInstance();
  locator.registerSingleton<LocalStorageHandler>(localStorageHandler);
}

class LocalUser extends ChangeNotifier {

  var localStorageHandler = locator<LocalStorageHandler>();

  User _user = null;

  User getUser() {
    return localStorageHandler.user;
  }

  void setUser(User newUser) {
    _user = newUser;
    localStorageHandler.user = _user;
    notifyListeners();
  }
}