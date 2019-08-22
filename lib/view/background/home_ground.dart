import 'package:flutter/material.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'package:flutter_craft/utils/system_util.dart';

/// 主页的背景
class HomeGround extends StatefulWidget with BaseFrame {
  final _state = _HomeGroundState();

  @override
  State createState() => _state;

  @override
  bool canRecycle() {
    return _state.canRecycle();
  }

  @override
  void reset() {
    _state.reset();
  }

  @override
  void update() {
    _state.update();
  }

  @override
  void render() {
    _state.render();
  }
}

class _HomeGroundState extends BaseState<HomeGround> with BaseFrame {
  final _bgStateStream = StreamController<int>();

  int _bgState = 0;
  int _bgStateNum = 0;

  @override
  void init() {}

  @override
  void dispose() {
    _bgStateStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bgStateStream.stream,
      initialData: 0,
      builder: (context, snapshot) {
        final state = snapshot.data;

        return Stack(
          children: List.generate(20, (index) {
            return Offstage(
              offstage: state != index,
              child: Image.asset(
                "images/home_bg${index + 1}.jpg",
                width: getScreenWidth(context),
                height: getScreenHeight(context),
                fit: BoxFit.fill,
              ),
            );
          }),
        );
      },
    );
  }

  @override
  bool canRecycle() {
    return false;
  }

  @override
  void update() {
    _bgState++;
    if (_bgState == 140) {
      _bgState = 0;
    }

    _bgStateNum = _bgState ~/ 7;
  }

  @override
  void render() {
    streamAdd(_bgStateStream, _bgStateNum);
  }

  @override
  void reset() {}
}
