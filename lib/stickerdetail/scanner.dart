import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import 'scannerCamera.dart';

class Scanner extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function stickerRecognized;

  Scanner(this.cameras, this.stickerRecognized);

  @override
  _ScannerState createState() => new _ScannerState();
}

class _ScannerState extends State<Scanner> {
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ScannerCamera(
            widget.cameras,
            _model,
            widget.stickerRecognized
          ),
        ],
      ),
    );
  }
}
