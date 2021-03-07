import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'models.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;
  final Function returnPicture;

  Camera(this.cameras, this.model, this.setRecognitions, this.returnPicture);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller;
  bool isDetecting = false;

  bool stickerDetected = false;
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
              threshold: 0.8,
            ).then((recognitions) {
              int endTime = new DateTime.now().millisecondsSinceEpoch;
              print("Detection took ${endTime - startTime}");

              widget.setRecognitions(recognitions, img.height, img.width);

              if (recognitions.length > 0) {
                numberOfDetections++;
                if (numberOfDetections >= 5) {
                  stickerDetected = true;
                  controller.stopImageStream();
                  // hide recognition bounds
                  widget.setRecognitions([], img.height, img.width);
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
            Align(
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      if(stickerDetected) {
                        final image = await controller.takePicture();
                        widget.returnPicture(image);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Take'),
                    style: ButtonStyle(
                        backgroundColor: (stickerDetected
                            ? MaterialStateProperty.all<Color>(Colors.blue)
                            : MaterialStateProperty.all<Color>(
                                Colors.blueGrey))),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              alignment: Alignment(0, .7),
            )
          ],
        ));
  }
}
