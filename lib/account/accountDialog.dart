import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/account/collectedStickerList.dart';
import 'package:flutter_realtime_detection/account/signInScreen.dart';
import 'package:flutter_realtime_detection/models/User.dart';
import 'package:provider/provider.dart';

import '../graphqlHandler.dart';

import '../localStorageHandler.dart';
import '../locator.dart';

class AccountDialog extends StatefulWidget {
  final Function(String text, {Color backgroundColor}) showSnackbar;

  AccountDialog(this.showSnackbar);

  @override
  _AccountDialogState createState() => new _AccountDialogState();
}

class _AccountDialogState extends State<AccountDialog> {
  GraphQLHandler graphQLHandler = GraphQLHandler();

  List<String> _collectedStickers;

  var localStorageHandler = locator<LocalStorageHandler>();

  @override
  void initState() {
    super.initState();

    _setupCollectedStickers();
  }

  _setupCollectedStickers() async {
    await Future.delayed(Duration(seconds: 1));

    var collectedStickers = await graphQLHandler.getCollectedStickerList();

    setState(() {
      _collectedStickers = collectedStickers;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user =
        Provider.of<LocalUser>(context, listen: true).getUser();

    if (user == null) {
      return SignInScreen(widget.showSnackbar);
    } else {
      return Container(
          padding: const EdgeInsets.all(16),
          child: Column(children: <Widget>[
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (_collectedStickers != null) CStickerList(_collectedStickers),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () {
                localStorageHandler.removeToken();

                Provider.of<LocalUser>(context, listen: false)
                    .setUser(null);

                widget.showSnackbar("Logged out.");
                Navigator.of(context).pop();
              },
            )
          ], mainAxisSize: MainAxisSize.min));
    }
  }
}
