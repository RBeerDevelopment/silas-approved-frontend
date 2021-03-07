import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/addStickerDialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';
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

  static const data = [
    {
      "id": "abc",
      "coordinates": {"lat": 48.1351, "long": 11.5820},
      "imgUrl": "abcde.de",
      "creator": "Robin",
      "createdAt": "2020-03-21",
      "stickerType": "original"
    },
    {
      "id": "def",
      "coordinates": {"lat": 47.1351, "long": 12.5820},
      "imgUrl": "abcde.de",
      "creator": "Robin",
      "createdAt": "2020-03-21",
      "stickerType": "original"
    },
    {
      "id": "ghi",
      "coordinates": {"lat": 48.1351, "long": 10.5820},
      "imgUrl": "abcde.de",
      "creator": "Robin",
      "createdAt": "2020-03-21",
      "stickerType": "original"
    }
  ];

  Completer<GoogleMapController> _controller = Completer();

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  Set<Marker> markers = new Set(); // CLASS MEMBER, MAP OF MARKS

  Future<void> _onMapCreated(GoogleMapController _cntlr) async {
    await LocationPermissions().requestPermissions();
    Location _location = Location();
    LocationData loc = await _location.getLocation();
    _cntlr.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(loc.latitude, loc.longitude), zoom: 15),
      ),
    );
  }

  void _addMarker() {
    var markerIdVal = math.Random.secure().nextInt(200).toString();

    final Set<Marker> newMarkers = data.map((item) {
      return Marker(markerId: MarkerId(item['id']), position: LatLng((item['coordinates'] as Map)['lat'], (item['coordinates'] as Map)['long']),
          infoWindow: InfoWindow(title: item['creator'], snippet: '*')
      );
    }).toSet();

    setState(() {
      // adding a new marker to map
      markers = newMarkers;
    });
  }

  _showAddStickerDialog() {
    showDialog(context: context, builder: (_) =>
      AlertDialog(
        title: Text('Add Sticker'),
        content: AddStickerDialog(widget.cameras),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('Silas Approved'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: _initialcameraposition),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _onMapCreated(controller);
        },
        zoomControlsEnabled: false,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        myLocationEnabled: true,
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStickerDialog();
        },
        backgroundColor: Colors.blue.shade500,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
