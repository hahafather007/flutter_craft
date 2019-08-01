import 'package:flutter/material.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'dart:async';
import 'package:flutter_craft/view/page/game_page.dart';
import 'package:flutter_craft/utils/timer_util.dart';

class HomePage extends StatefulWidget {
  @override
  State createState() => HomeState();
}

class HomeState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    TimerUtil.init();
    Timer(const Duration(milliseconds: 200), () {
      push(context, page: GamePage());
    });
  }

  @override
  void dispose() {
    TimerUtil.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
