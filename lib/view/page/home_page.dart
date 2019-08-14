import 'package:flutter/material.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'dart:async';
import 'package:flutter_craft/view/page/game_page.dart';
import 'package:flutter_craft/view/background/home_ground.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  @override
  State createState() => HomeState();
}

class HomeState extends BaseState<HomePage> with BaseFrame {
  AudioPlayer _audioPlayer;

  @override
  void init() {
    TimerUtil.init();

    // bgm
    final audio = AudioCache();
    audio.loop("home_bg.mp3").then((v) => _audioPlayer = v);
  }

  @override
  void dispose() {
    TimerUtil.dispose();
    _audioPlayer?.release();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          HomeGround(),
        ],
      ),
    );
  }

  @override
  void render() {}

  @override
  void update() {}

  @override
  bool canRecycle() {
    return false;
  }
}
