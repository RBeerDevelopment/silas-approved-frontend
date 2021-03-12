import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  Map<String, dynamic> _user = {  };

  Map<String, dynamic> getUser() {
    return _user;
  }

  void setUser(Map newUser) {
    _user = newUser;
    notifyListeners();
  }
}