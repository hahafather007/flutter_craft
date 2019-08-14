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
  HomeGround _ground;
  AudioPlayer _audioPlayer;

  @override
  void init() {
    TimerUtil.init();

    _ground = HomeGround();

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
          // 背景图
          _ground,

          // 按钮
          _buildBtns(),
        ],
      ),
    );
  }

  /// 界面上的按钮
  Widget _buildBtns() {
    return Positioned.fill(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _buildInkBtn(
                text: "Play",
                onTap: () async {
                  _audioPlayer.pause();
                  _ground.pause();
                  await push(context, page: GamePage());
                  _audioPlayer.resume();
                  _ground.resume();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInkBtn({@required String text, VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            "images/btn.png",
            width: 100,
            height: 50,
            fit: BoxFit.fill,
          ),
          Text(
            "$text",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
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
