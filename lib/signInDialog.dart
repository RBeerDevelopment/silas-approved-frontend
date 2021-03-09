import 'package:flutter/material.dart';

import 'graphqlHandler.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SignInDialog extends StatefulWidget {
  SignInDialog();

  @override
  _SignInDialogState createState() => new _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  GraphQLHandler graphQLHandler = GraphQLHandler();
  SharedPreferences _prefs;
  String _prefsTokenKey = "graphqlToken";
  String _token = "";
  TextEditingController _emailController, _passwordController, _nameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();

    _setupPrefs();
  }

  _setupPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey(_prefsTokenKey)) {
      setState(() {
        _token = _prefs.getString(_prefsTokenKey);
      });
      debugPrint("Token: " + _token);
    }
    debugPrint("No token");
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
    if (_token.isEmpty) {
      return Column(children: <Widget>[
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
          ),
          controller: _emailController,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
          ),
          controller: _passwordController,
          obscureText: true,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: 'Name',
          ),
          controller: _nameController,
        ),
        Padding(
          padding: EdgeInsets.only(top: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text('Sign Up'),
                onPressed: () {
                  graphQLHandler.signUp(
                      _emailController.text, _passwordController.text,
                      _nameController.text);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Login'),
                onPressed: () async {
                  graphQLHandler.login(
                      _emailController.text, _passwordController.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        )
      ], mainAxisSize: MainAxisSize.min);
    } else {
      return Text('Already logged in');
    }
  }

}
