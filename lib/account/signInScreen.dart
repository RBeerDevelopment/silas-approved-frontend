import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../graphqlHandler.dart';
import '../localStorageHandler.dart';
import '../locator.dart';
import '../user.dart';

class SignInScreen extends StatefulWidget {
  final Function(String text, {Color backgroundColor}) showSnackbar;

  SignInScreen(this.showSnackbar);

  @override
  _SignInScreenState createState() => new _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  TextEditingController _emailController, _passwordController, _nameController;

  GraphQLHandler graphQLHandler = GraphQLHandler();

  var localStorageHandler = locator<LocalStorageHandler>();

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  _handleUserResult(Map<String, dynamic> user, BuildContext context) {
    if (user.isNotEmpty) {
      Provider.of<User>(context, listen: false).setUser(user);
      widget.showSnackbar("Logged in successfully.");
    } else {
      widget.showSnackbar("Login failed.", backgroundColor: Colors.red);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
          width: 70.0,
          height: 70.0,
          child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(child: CircularProgressIndicator())));
    } else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: new IconButton(icon: new Icon(null), onPressed: () {}),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Sign Up'),
                Tab(text: 'Log In'),
              ],
            ),
            title: Text('Account'),
          ),
          body: TabBarView(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(children: <Widget>[
                  AutofillGroup(
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: ElevatedButton(
                        child: Text('Sign Up'),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          Map<String, dynamic> user =
                              await graphQLHandler.signUp(
                                  _emailController.text,
                                  _passwordController.text,
                                  _nameController.text);
                          _handleUserResult(user, context);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.pinkAccent)),
                  )
                ], mainAxisSize: MainAxisSize.min),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(children: <Widget>[
                  AutofillGroup(
                    child: Column(
                      children: [
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
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: ElevatedButton(
                      child: Text('Login'),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        Map<String, dynamic> user = await graphQLHandler.login(
                            _emailController.text, _passwordController.text);
                        _handleUserResult(user, context);
                      },
                      style:
                          ElevatedButton.styleFrom(primary: Colors.pinkAccent),
                    ),
                  )
                ], mainAxisSize: MainAxisSize.min),
              ),
            ],
          ),
        ),
      );
    }
  }
}
