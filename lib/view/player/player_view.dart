import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'package:flutter_craft/view/base_craft.dart';

class PlayerView extends StatefulWidget with BaseCraft {
  final _state = _PlayerState();

  @override
  State createState() => _state;

  @override
  Rect getRect() {
    return _state.getRect();
  }

  @override
  Offset getFirePos() {
    return _state.getFirePos();
  }

  Offset getCenterPos() {
    return _state.getCenterPos();
  }

  @override
  bool get canAttack => _state.canAttack;

  @override
  Future<bool> attack(int value) => _state.attack(value);
}

class _PlayerState extends BaseState<PlayerView> with BaseFrame, BaseCraft {
  final _posStream = StreamController<Offset>();
  final _showStream = StreamController<bool>();
  final _playerH = 40.0;
  final _playerW = 40.0;

  Offset _position;
  int _hp;

  /// 无敌状态
  bool _invincible = false;

  @override
  void init() {
    _hp = 3;
    _position = Offset(getScreenWidth(context) / 2 - _playerW / 2,
        getScreenHeight(context) - 80);

    bindSub(TimerUtil.frameStream.listen((_) => nextFrame()));
  }

  @override
  void dispose() {
    _posStream.close();
    _showStream.close();

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
              initialData: _position,
              stream: _posStream.stream,
              builder: (context, snapshot) {
                final Offset offset = snapshot.data;

                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: StreamBuilder(
                    stream: _showStream.stream,
                    initialData: true,
                    builder: (context, snapshot) {
                      final show = snapshot.data;

                      return AnimatedOpacity(
                        opacity: show ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.airplanemode_active,
                          size: _playerH,
                        ),
                      );
                    },
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
    return _hp <= 0;
  }

  @override
  void nextFrame() {
    if (_hp == null || _position == null) return;

    streamAdd(_posStream, _position);
  }

  /// 调用该方法表示手指移动了多少像素
  void move(double xNum, double yNum) async {
    var dx = _position.dx + xNum;
    var dy = _position.dy + yNum;

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

    _position = Offset(dx, dy);
  }

  @override
  Rect getRect() {
    if (_position == null) {
      return null;
    }

    return Rect.fromPoints(
        _position, Offset(_position.dx + _playerW, _position.dy + _playerH));
  }

  @override
  Offset getFirePos() {
    return Offset(_position.dx + _playerW / 2, _position.dy);
  }

  Offset getCenterPos() {
    return Offset(_position.dx + _playerW / 2, _position.dy + _playerH / 2);
  }

  @override
  bool get canAttack => !_invincible;

  @override
  Future<bool> attack(int value) async {
    if (_invincible) {
      return false;
    }

//    _hp -= value;

    // 被击中后的无敌状态
    if (_hp > 0) {
      _invincible = true;
      streamAdd(_showStream, false);
      await Future.delayed(const Duration(milliseconds: 300));
      streamAdd(_showStream, true);
      await Future.delayed(const Duration(milliseconds: 300));
      streamAdd(_showStream, false);
      await Future.delayed(const Duration(milliseconds: 300));
      streamAdd(_showStream, true);
      await Future.delayed(const Duration(milliseconds: 300));
      streamAdd(_showStream, false);
      await Future.delayed(const Duration(milliseconds: 300));
      streamAdd(_showStream, true);
      _invincible = false;
    }

    return _hp <= 0;
  }
}
