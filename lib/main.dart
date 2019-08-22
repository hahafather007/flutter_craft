import 'package:flutter/material.dart';
import 'package:flutter_craft/view/page/home_page.dart';
import 'package:flutter/services.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        fontFamily: "AppFont",
      ),
    );
  }
}
