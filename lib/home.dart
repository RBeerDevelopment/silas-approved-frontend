import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/signInDialog.dart';
import 'package:flutter_realtime_detection/addStickerDialog.dart';
import 'package:flutter_realtime_detection/graphqlHandler.dart';
import 'package:flutter_realtime_detection/stickerDetailDialog.dart';
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

  var _data = [];
  Location _location;
  LocationData _myLocation;

  Completer<GoogleMapController> _controller = Completer();

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  Set<Marker> markers = new Set(); // CLASS MEMBER, MAP OF MARKS

  Future<Null> _setupLocation() async {
    await LocationPermissions().requestPermissions();
    _location = Location();
    _myLocation = await _location.getLocation();
  }


  Future<void> _onMapCreated(GoogleMapController _cntlr) async {

    await _setupLocation();

    _cntlr.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_myLocation.latitude, _myLocation.longitude), zoom: 7),
      ),
    );

    _fetchStickers();
  }

  void _fetchStickers() async {
    GraphQLHandler graphQLHandler = GraphQLHandler();

    // todo remove this
    await Future.delayed(Duration(seconds: 1));

    _data = await graphQLHandler.getAllStickerLocations();
    _updateMarkers();
  }

  void _updateMarkers() {

    final Set<Marker> newMarkers = _data.map((sticker) {
      return Marker(
          markerId: MarkerId(sticker['id']),
          position: LatLng(sticker['location']['lat'], sticker['location']['lng']),
          onTap: () {
            showDialog(
                context: context,
                builder:  (_) => AlertDialog(
                  title: Text('Sign In / Sign Up'),
                  content: StickerDetailDialog(sticker, _location),
                )
            );
          });
    }).toSet();

    setState(() {
      // adding a new marker to map
      markers = newMarkers;
    });
  }

  _showAddStickerDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Add Sticker'),
              content: AddStickerDialog(widget.cameras),
            ));
  }

  _showSignInDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Sign In / Sign Up'),
        content: SignInDialog(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('Silas Approved'),
        backgroundColor: Colors.blue.shade900,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Account',
            onPressed: () {
              _showSignInDialog();
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
