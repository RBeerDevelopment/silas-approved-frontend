import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;


class ScannerCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String model;
  final Function stickerRecognized;

  ScannerCamera(this.cameras, this.model, this.stickerRecognized);

  @override
  _ScannerCameraState createState() => new _ScannerCameraState();
}

class _ScannerCameraState extends State<ScannerCamera> {
  CameraController controller;
  bool isDetecting = false;

  var numberOfDetections = 0;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras.first,
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;
            Tflite.detectObjectOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              model: "SSDMobileNet",
              imageHeight: img.height,
              imageWidth: img.width,
              imageMean: 255,
              imageStd: 255,
              numResultsPerClass: 1,
              threshold: 0.75,
            ).then((recognitions) {
              int endTime = new DateTime.now().millisecondsSinceEpoch;
              print("Detection took ${endTime - startTime}");

              if (recognitions.length > 0) {
                numberOfDetections++;
                if (numberOfDetections >= 3) {
                  controller.stopImageStream();
                  widget.stickerRecognized();
                  Navigator.of(context).pop();
                  // hide recognition bounds
                }
              }
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
        maxHeight: screenRatio > previewRatio
            ? screenH
            : screenW / previewW * previewH,
        maxWidth: screenRatio > previewRatio
            ? screenH / previewH * previewW
            : screenW,
        child: Stack(
          children: [
            CameraPreview(controller),
          ],
        ));
  }
}
