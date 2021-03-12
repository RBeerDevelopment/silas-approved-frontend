import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/account/collectedStickerList.dart';
import 'package:provider/provider.dart';

import '../graphqlHandler.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../user.dart';

class AccountDialog extends StatefulWidget {
  AccountDialog();

  @override
  _AccountDialogState createState() => new _AccountDialogState();
}

class _AccountDialogState extends State<AccountDialog> {
  GraphQLHandler graphQLHandler = GraphQLHandler();
  SharedPreferences _prefs;
  String _prefsTokenKey = "graphqlToken";
  String _token = "";
  TextEditingController _emailController, _passwordController, _nameController;

  bool _isLoading = false;
  List<String> _collectedStickers;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();

    _setupPrefs();

    _setupCollectedStickers();
  }

  _setupCollectedStickers() async {
    await Future.delayed(Duration(seconds: 1));

    var collectedStickers = await graphQLHandler.getCollectedStickerList();

    setState(() {
      _collectedStickers = collectedStickers;
    });
  }

  _setupPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey(_prefsTokenKey)) {
      setState(() {
        _token = _prefs.getString(_prefsTokenKey);
      });
      debugPrint("Token: " + _token);
    } else {
      debugPrint("No token");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> user = Provider.of<User>(context).getUser();

    if (_isLoading) {
      return Container(
          width: 70.0,
          height: 70.0,
          child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(child: CircularProgressIndicator())));
    } else if (user == null || user.isEmpty) {
      return Column(children: <Widget>[
        AutofillGroup(
          child: Column(children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              controller: _emailController,
              autofillHints: const <String>[AutofillHints.email],
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              controller: _passwordController,
              obscureText: true,
              autofillHints: const <String>[AutofillHints.password],
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              controller: _nameController,
              autofillHints: const <String>[AutofillHints.name],
            ),
          ],),
        ),

        Padding(
          padding: EdgeInsets.only(top: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text('Sign Up'),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  Map<String, dynamic> user = await graphQLHandler.signUp(
                      _emailController.text,
                      _passwordController.text,
                      _nameController.text);
                  Provider.of<User>(context, listen: false).setUser(user);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Login'),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  Map<String, dynamic> user = await graphQLHandler.login(
                      _emailController.text, _passwordController.text);
                  Provider.of<User>(context, listen: false).setUser(user);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        )
      ], mainAxisSize: MainAxisSize.min);
    } else {
      return Column(children: <Widget>[
        if (_collectedStickers != null) CStickerList(_collectedStickers),
        TextButton(
          child: Text('Sign Out'),
          onPressed: () {
            _prefs.remove(_prefsTokenKey);
            setState(() {
              _token = '';
            });
          },
        )
      ], mainAxisSize: MainAxisSize.min);
    }
  }
}
