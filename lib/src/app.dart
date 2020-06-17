import 'package:flutter/material.dart';
import 'fingerprint/fingerprint_game.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fingerprint Scanner Hack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FingerPrintHack() ,
    );
  }
}
