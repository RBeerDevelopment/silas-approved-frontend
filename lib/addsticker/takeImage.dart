import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import '../bndbox.dart';

class TakeImage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function returnPicture;

  TakeImage(this.cameras, this.returnPicture);

  @override
  _TakeImageState createState() => new _TakeImageState();
}

class _TakeImageState extends State<TakeImage> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  loadModel() async {
    await Tflite.loadModel(
            model: "assets/silas-approved.tflite",
            labels: "assets/silas-approved.txt");
    }


  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
              children: [
                Camera(
                  widget.cameras,
                  _model,
                  setRecognitions,
                  widget.returnPicture,
                ),
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width,
                    _model),
              ],
            ),
    );
  }
}
