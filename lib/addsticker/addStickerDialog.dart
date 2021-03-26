import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'takeImage.dart';
import '../graphqlHandler.dart';
import 'package:location/location.dart';

class AddStickerDialog extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(String text, { Color backgroundColor }) showSnackbar;

  AddStickerDialog(this.cameras, this.showSnackbar);

  @override
  _AddStickerDialogState createState() => new _AddStickerDialogState();
}

class _AddStickerDialogState extends State<AddStickerDialog> {

  GraphQLHandler graphQLHandler = GraphQLHandler();
  TextEditingController _nameController;
  String _imagePath = "";
  
  final _nameFieldKey = GlobalKey<FormFieldState>();

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

  bool _isReadyToPost() {
    return _nameFieldKey.currentState.validate() && _imagePath.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: <Widget>[
      TextFormField(
        key: _nameFieldKey,
        validator: MultiValidator([
          RequiredValidator(errorText: 'Please enter a name.'),
          MaxLengthValidator(32, errorText: 'Name is too long.')
        ]),
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
        icon: const Icon(Icons.camera_alt_outlined),
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
              if(_isReadyToPost()) {
                Location _location = Location();
                LocationData loc = await _location.getLocation();

                bool result = await graphQLHandler.postSticker(
                    context: context,
                    name: _nameController.text,
                    lat: loc.latitude,
                    lng: loc.longitude,
                    stickerImage: File(_imagePath));
                if (result) {
                  widget.showSnackbar('Posted sticker.');
                } else {
                  widget.showSnackbar(
                      'Error posting sticker.', backgroundColor: Colors.red);
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      )
    ], mainAxisSize: MainAxisSize.min));
  }
}
