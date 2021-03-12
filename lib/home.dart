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
import 'package:provider/provider.dart';

import 'user.dart';

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

  Map<String, dynamic> _user;

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
    _data = await _graphQLHandler.getAllStickerLocations();
    _updateMarkers();
  }

  void scannedSticker(String id, String name) {
    final snackBar = SnackBar(content: Text('Sticker $name scanned.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.blue);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _graphQLHandler.scanSticker(id);
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
                  title: Text(sticker['name']),
                  content: StickerDetailDialog(sticker, _location, widget.cameras, scannedSticker),
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
        title: (_user == null || _user.isEmpty) ? const Text('Account') : Text(_user['name']),
        content: AccountDialog(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    _user = Provider.of<User>(context).getUser();

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
