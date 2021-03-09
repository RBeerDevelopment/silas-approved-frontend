import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:flutter_realtime_detection/utils.dart';

class StickerDetailDialog extends StatefulWidget {

  final Map<String, dynamic> sticker;
  final Location location;

  StickerDetailDialog(this.sticker, this.location);

  @override
  _StickerDetailDialogState createState() => new _StickerDetailDialogState();
}

class _StickerDetailDialogState extends State<StickerDetailDialog> {

  bool _isInRange = false;

  @override
  void initState() {
    super.initState();

    _calcIsInRange(widget.sticker['location']['lat'], widget.sticker['location']['lng']);

  }

  Future<Null> _calcIsInRange(lat, lng) async {
    debugPrint("isInRange() called");
    LocationData lData = await widget.location.getLocation();

    debugPrint(lData.latitude.toString() + " " + lData.longitude.toString());
    double distance = calcDistance(lData.latitude, lData.longitude, lat, lng);
    debugPrint(distance.toString());
    setState(() {
      _isInRange = (distance <= 500);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Creator: ${widget.sticker['createdBy']['name']}'),
        Image.network(
          widget.sticker['imageUrl'],
          height: 200,
          width: 200,
          fit: BoxFit.fitWidth,
        ),
        if(_isInRange)
          ElevatedButton(onPressed: () {}, child: Text('Scan'))
      ],
    );
  }

}
