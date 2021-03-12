import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'takeImage.dart';
import '../graphqlHandler.dart';
import 'package:location/location.dart';

class AddStickerDialog extends StatefulWidget {
  final List<CameraDescription> cameras;

  AddStickerDialog(this.cameras);

  @override
  _AddStickerDialogState createState() => new _AddStickerDialogState();
}

class _AddStickerDialogState extends State<AddStickerDialog> {

  GraphQLHandler graphQLHandler = GraphQLHandler();
  TextEditingController _nameController;
  String _imagePath = "";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _returnPicture(XFile xFile) {
    setState(() {
      _imagePath = xFile.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TextField(
        decoration: InputDecoration(
          labelText: 'Location Name',
        ),
        controller: _nameController,
      ),
      if (_imagePath != "")
        Padding(
          padding: EdgeInsets.all(12),
          child: Image.file(
            File(_imagePath),
            height: 300,
            fit: BoxFit.fitHeight,
          ),
        ),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TakeImage(widget.cameras, _returnPicture)));
        },
        label: const Text('Take Picture'),
        icon: const Icon(Icons.camera_alt_outlined)
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Ok'),
            onPressed: () async {
              Location _location = Location();
              LocationData loc = await _location.getLocation();

              graphQLHandler.postSticker(
                  context: context,
                  name: _nameController.text,
                  lat: loc.latitude,
                  lng: loc.longitude,
                  stickerImage: File(_imagePath));
              Navigator.of(context).pop();
            },
          ),
        ],
      )
    ], mainAxisSize: MainAxisSize.min);
  }
}
