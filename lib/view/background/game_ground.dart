import 'package:flutter/material.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'dart:math';

/// 游戏进行中的背景
class GameGround extends StatefulWidget with BaseFrame {
  final _state = _GameGroundState();

  @override
  State createState() => _state;

  @override
  bool canRecycle() {
    return _state.canRecycle();
  }

  @override
  void update() {
    _state.update();
  }

  @override
  void reset() {
    _state.reset();
  }

  @override
  void render() {
    _state.render();
  }
}

class _GameGroundState extends BaseState<GameGround> with BaseFrame {
  final _img = Random().nextDouble() > 0.5 ? "bg1.jpg" : "bg2.jpg";
  final _moveStream = StreamController<double>();

  Widget _imgView;
  double _imgHeight;
  double _imgWidth;
  double _moveY = 0;

  @override
  void init() {
    _imgWidth = getScreenWidth(context);
    _imgHeight = _imgWidth / 225 * 400;
    _imgView = Image.asset(
      "images/$_img",
      width: _imgWidth,
      height: _imgHeight,
      fit: BoxFit.fill,
    );
  }

  @override
  void dispose() {
    _moveStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _moveStream.stream,
      initialData: _moveY,
      builder: (context, snapshot) {
        final moveY = snapshot.data;

        return Positioned(
          child: Column(
            children: <Widget>[
              _imgView,
              _imgView,
            ],
          ),
          top: -_imgHeight + moveY,
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
    if (_imgHeight == null) return;

    _moveY += 2;
    if (_moveY >= _imgHeight) {
      _moveY = 0;
    }
  }

  @override
  void render() {
    streamAdd(_moveStream, _moveY);
  }

  @override
  void reset() {}
}
