import 'package:flutter/material.dart';

class CStickerList extends StatelessWidget {
  const CStickerList(this.stickers);

  final List<String> stickers;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = stickers
        .map((stickerName) => ListTile(
              title: Text(stickerName),
              onTap: () {
                debugPrint(stickerName);
              },
            ))
        .toList();

    return Column(
      children: [
        const Divider(
          height: 12,
          thickness: 2,
        ),
        Padding(
            padding: EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Text(
                  'Collected Stickers (${stickers.length})',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 400,
                  width: 200,
                  child: ListView(
                    shrinkWrap: true,
                    children: widgetList,
                  ),
                )
              ],
            ))
      ],
    );
  }
}
