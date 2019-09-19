import 'package:flutter/material.dart';
import 'package:flutter_craft/view/page/splash_page.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:auto_orientation/auto_orientation.dart';

void main() {
  Observable.fromFuture(
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]))
      .asyncMap((_) => SystemChrome.setEnabledSystemUIOverlays([]))
      .asyncMap((_) => AutoOrientation.portraitUpMode())
      .listen((_) => runApp(CraftApp()));
}

class CraftApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashPage(),
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        fontFamily: "AppFont",
      ),
    );
  }
}
