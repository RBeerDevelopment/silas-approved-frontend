import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'takeImage.dart';

class AddStickerDialog extends StatefulWidget {
  final List<CameraDescription> cameras;

  AddStickerDialog(this.cameras);

  @override
  _AddStickerDialogState createState() => new _AddStickerDialogState();
}

class _AddStickerDialogState extends State<AddStickerDialog> {
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
        Image.file(
          File(_imagePath),
          height: 500,
        ),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TakeImage(widget.cameras, _returnPicture)));
        },
        child: const Text('Take Picture'),
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      )
    ], mainAxisSize: MainAxisSize.min);
  }
}
