import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/locator.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'user.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: User()),
        ],
        child: MaterialApp(
          title: 'Silas Approved',
          theme: ThemeData(
            primaryColor: Colors.teal,
            brightness: Brightness.light,
            accentColor: Colors.pinkAccent,
            buttonColor: Colors.pinkAccent,
          ),
          home: HomePage(cameras),
        ));
  }
}
