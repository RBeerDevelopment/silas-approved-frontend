import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  Completer<GoogleMapController> _controller = Completer();
  Location _location = Location();

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);

  void _onMapCreated(GoogleMapController _cntlr)
  {
    _location.onLocationChanged.listen((l) {
      _cntlr.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('Silas Approved'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: _initialcameraposition),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _onMapCreated(controller)
        },
        zoomControlsEnabled: false,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        myLocationEnabled: true,

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToTheLake,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  // @override
  // Widget build(BuildContext context) {
  //   Size screen = MediaQuery.of(context).size;
  //   return Scaffold(
  //     body: _model == ""
  //         ? Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           ElevatedButton(
  //             child: const Text(ssd),
  //             onPressed: () => onSelect(ssd),
  //           ),
  //           ElevatedButton(
  //             child: const Text(yolo),
  //             onPressed: () => onSelect(yolo),
  //           ),
  //           ElevatedButton(
  //             child: const Text(mobilenet),
  //             onPressed: () => onSelect(mobilenet),
  //           ),
  //           ElevatedButton(
  //             child: const Text(silas),
  //             onPressed: () => onSelect(silas),
  //           ),
  //           ElevatedButton(
  //             child: const Text(posenet),
  //             onPressed: () => onSelect(posenet),
  //           ),
  //         ],
  //       ),
  //     )
  //         : Stack(
  //       children: [
  //         Camera(
  //           widget.cameras,
  //           _model,
  //           setRecognitions,
  //         ),
  //         BndBox(
  //             _recognitions == null ? [] : _recognitions,
  //             math.max(_imageHeight, _imageWidth),
  //             math.min(_imageHeight, _imageWidth),
  //             screen.height,
  //             screen.width,
  //             _model),
  //       ],
  //     ),
  //   );
  // }
}
