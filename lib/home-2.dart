import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/addStickerDialog.dart';
import 'package:flutter_realtime_detection/graphqlHandler.dart';
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

  Completer<GoogleMapController> _controller = Completer();

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  Set<Marker> markers = new Set(); // CLASS MEMBER, MAP OF MARKS

  Future<void> _onMapCreated(GoogleMapController _cntlr) async {
    await LocationPermissions().requestPermissions();
    Location _location = Location();
    LocationData loc = await _location.getLocation();
    _cntlr.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(loc.latitude, loc.longitude), zoom: 7),
      ),
    );

    _fetchStickers();
  }

  void _fetchStickers() async {
    _data = await GraphQLHandler.getAllStickerLocations(() {});
    debugPrint(_data.toString());
    _updateMarkers();
  }

  void _updateMarkers() {
    debugPrint('updateMakers called');
    final Set<Marker> newMarkers = _data.map((sticker) {
      Map location = sticker['location'];
      debugPrint(location.toString());
      return Marker(
          markerId: MarkerId(sticker['id']),
          position: LatLng(location['lat'], location['lng']),
          onTap: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text(sticker['name']),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Creator: ${sticker['createdBy']['name']}'),
                          Image.network(
                            sticker['imageUrl'],
                            height: 200,
                            width: 200,
                            fit: BoxFit.fitWidth,
                          )
                        ],
                      ),
                    ));
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('Silas Approved'),
        backgroundColor: Colors.blue.shade900,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Stickers',
            onPressed: () {
              _fetchStickers();
            },
          ),
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
