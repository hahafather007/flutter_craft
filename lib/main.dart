import 'package:flutter/material.dart';
import 'package:flutter_craft/view/page/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(platform: TargetPlatform.iOS),
    );
  }
}
