import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/account/accountDialog.dart';
import 'package:flutter_realtime_detection/addsticker/addStickerDialog.dart';
import 'package:flutter_realtime_detection/graphqlHandler.dart';
import 'package:flutter_realtime_detection/stickerdetail/stickerDetailDialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';

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

  GraphQLHandler _graphQLHandler = GraphQLHandler();

  var _data = [];
  Location _location;
  LocationData _myLocation;

  Completer<GoogleMapController> _controller = Completer();

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  Set<Marker> _markers = new Set(); // CLASS MEMBER, MAP OF MARKS

  Future<Null> _setupLocation() async {
    await LocationPermissions().requestPermissions();
    _location = Location();
    _myLocation = await _location.getLocation();
  }

  _showSnackbarWithText(String text,
      {Color backgroundColor = Colors.pink}) {
    final snackBar = SnackBar(
      content: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _onMapCreated(GoogleMapController _cntlr) async {
    await _setupLocation();

    _cntlr.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(_myLocation.latitude, _myLocation.longitude),
            zoom: 7),
      ),
    );

    _fetchStickers();
  }

  void _fetchStickers() async {
    _data = await _graphQLHandler.getAllStickerLocations();
    _setupMarkers();
    // subscribe to new sticker creations
    _graphQLHandler.subscribeToStickers(_addStickerToMap);
  }

  void _addStickerToMap(Map<String, dynamic> sticker) {
    print("add sticker called with");
    print(sticker);

    Marker newMarker = _createMarker(sticker);
    setState(() {
      _markers.add(newMarker);
    });
  }
  
  void scannedSticker(String id, String name) async {
    bool success = await _graphQLHandler.scanSticker(id);
    if (success) {
      _showSnackbarWithText('Sticker $name scanned.');
    } else {
      _showSnackbarWithText('Error scanning $name.',
          backgroundColor: Colors.red);
    }
  }
  
  Marker _createMarker(Map<String, dynamic> sticker) {
    return Marker(
        markerId: MarkerId(sticker['id']),
        position:
        LatLng(sticker['location']['lat'].toDouble(), sticker['location']['lng'].toDouble()),
        onTap: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(sticker['name']),
                content: StickerDetailDialog(
                    sticker, _location, widget.cameras, scannedSticker, _showSnackbarWithText),
              ));
        });
  }

  void _setupMarkers() {
    final Set<Marker> newMarkers = _data.map((sticker) {
      return _createMarker(sticker);
    }).toSet();

    setState(() {
      // adding a new marker to map
      _markers = newMarkers;
    });
  }

  _showAddStickerDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Add Sticker'),
              content: AddStickerDialog(widget.cameras, _showSnackbarWithText),
            ));
  }

  _showAccountDialog() {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              child: AccountDialog(_showSnackbarWithText),
            ));
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        title: const Text('Silas Approved'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Account',
            onPressed: () {
              _showAccountDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Stickers',
            onPressed: () {
              _fetchStickers();
            },
          )
        ],
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
        myLocationButtonEnabled: false,
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStickerDialog,
        // backgroundColor: Colors.blue.shade500,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
