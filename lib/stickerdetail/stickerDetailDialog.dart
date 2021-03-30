import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/models/Sticker.dart';
import 'package:flutter_realtime_detection/stickerdetail/scanner.dart';
import 'package:location/location.dart' as LocationLib;
import 'package:camera/camera.dart';

import 'package:flutter_realtime_detection/utils.dart';

class StickerDetailDialog extends StatefulWidget {
  final Sticker sticker;
  final LocationLib.Location location;
  final List<CameraDescription> cameras;
  final Function scannedSticker;

  final Function(String text, {Color backgroundColor}) showSnackbar;

  StickerDetailDialog(this.sticker, this.location, this.cameras,
      this.scannedSticker, this.showSnackbar);

  @override
  _StickerDetailDialogState createState() => new _StickerDetailDialogState();
}

class _StickerDetailDialogState extends State<StickerDetailDialog> {
  bool _isInRange = false;

  @override
  void initState() {
    super.initState();

    _calcIsInRange(
        widget.sticker.location.lat, widget.sticker.location.lng);
  }

  Future<Null> _calcIsInRange(lat, lng) async {
    debugPrint("isInRange() called");
    LocationLib.LocationData lData = await widget.location.getLocation();

    debugPrint(lData.latitude.toString() + " " + lData.longitude.toString());
    double distance = calcDistance(lData.latitude, lData.longitude, lat, lng);
    debugPrint(distance.toString());
    setState(() {
      _isInRange = (distance <= 500);
    });
  }

  void stickerRecognized() {
    widget.scannedSticker(widget.sticker.id, widget.sticker.name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Creator: ${widget.sticker.createdBy.name}'),
        Padding(
          padding: EdgeInsets.all(8),
          child: widget.sticker.imageUrl.isNotEmpty
              ? Image.network(
                  widget.sticker.imageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.fitWidth,
                )
              : Image.asset('assets/silas-approved.png',
                  height: 200, width: 200, fit: BoxFit.fitWidth),
        ),
        if (_isInRange)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Scanner(widget.cameras, stickerRecognized)));
            },
            label: const Text('Scan'),
            icon: const Icon(Icons.qr_code_scanner),
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close')),
      ],
    );
  }
}
