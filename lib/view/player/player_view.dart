import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/utils/timer_util.dart';

class PlayerView extends StatefulWidget {
  final _state = _PlayerState();

  @override
  State createState() => _state;

  Rect getRect() {
    return _state.getRect();
  }

  Offset getFirePos() {
    return _state.getFirePos();
  }

  Offset getCenterPos() {
    return _state.getCenterPos();
  }
}

class _PlayerState extends BaseState<PlayerView> with BaseFrame {
  final _posStream = StreamController<Offset>();
  final _playerH = 40.0;
  final _playerW = 40.0;

  Offset position;
  int hp;

  @override
  void init() {
    hp = 3;
    position = Offset(getScreenWidth(context) / 2 - _playerW / 2,
        getScreenHeight(context) - 80);

    bindSub(TimerUtil.frameStream.listen((_) => nextFrame()));
  }

  @override
  void dispose() {
    _posStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => move(details.delta.dx, details.delta.dy),
        child: Stack(
          children: <Widget>[
            StreamBuilder(
              initialData: position,
              stream: _posStream.stream,
              builder: (context, snapshot) {
                final Offset offset = snapshot.data;

                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: Icon(
                    Icons.airplanemode_active,
                    size: _playerH,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool canRecycle() {
    return hp <= 0;
  }

  @override
  void nextFrame() {
    if (hp == null || position == null) return;

    streamAdd(_posStream, position);
  }

  /// 调用该方法表示手指移动了多少像素
  void move(double xNum, double yNum) async {
    var dx = position.dx + xNum;
    var dy = position.dy + yNum;

    if (dx < -_playerW / 2) {
      dx = -_playerW / 2;
    } else if (dx > getScreenWidth(context) - _playerW / 2) {
      dx = getScreenWidth(context) - _playerW / 2;
    }

    if (dy < -_playerH / 2) {
      dy = -_playerH / 2;
    } else if (dy > getScreenHeight(context) - _playerH / 2) {
      dy = getScreenHeight(context) - _playerH / 2;
    }

    position = Offset(dx, dy);
  }

  Rect getRect() {
    return Rect.fromPoints(
        position, Offset(position.dx + _playerW, position.dy + _playerH));
  }

  Offset getFirePos() {
    return Offset(position.dx + _playerW / 2, position.dy);
  }

  Offset getCenterPos() {
    return Offset(position.dx + _playerW / 2, position.dy + _playerH / 2);
  }
}
