import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/models/User.dart';
import 'package:provider/provider.dart';

import '../graphqlHandler.dart';
import '../localStorageHandler.dart';
import '../locator.dart';
import 'accountForm.dart';

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

  GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

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

  _handleUserResult(User user, BuildContext context) {
    if (user != null) {
      Provider.of<LocalUser>(context, listen: false).setUser(user);
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
              child: const Center(child: const CircularProgressIndicator())));
    } else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(null), onPressed: () {}),
            bottom: const TabBar(
              tabs: [
                const Tab(text: 'Sign Up'),
                const Tab(text: 'Log In'),
              ],
            ),
            title: const Text('Account'),
          ),
          body: TabBarView(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                  AccountForm(
                    formKey: _signupFormKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    nameController: _nameController,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: ElevatedButton(
                        child: const Text('Sign Up'),
                        onPressed: () async {
                          if (_signupFormKey.currentState.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            User user =
                                await graphQLHandler.signUp(
                                    _emailController.text,
                                    _passwordController.text,
                                    _nameController.text);
                            _handleUserResult(user, context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.pinkAccent)),
                  )
                ], mainAxisSize: MainAxisSize.min)),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                  AccountForm(
                      formKey: _loginFormKey,
                      emailController: _emailController,
                      passwordController: _passwordController),
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: ElevatedButton(
                      child: const Text('Login'),
                      onPressed: () async {
                        if (_loginFormKey.currentState.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          User user =
                              await graphQLHandler.login(_emailController.text,
                                  _passwordController.text);
                          _handleUserResult(user, context);
                        }
                      },
                      style:
                          ElevatedButton.styleFrom(primary: Colors.pinkAccent),
                    ),
                  )
                ], mainAxisSize: MainAxisSize.min)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
