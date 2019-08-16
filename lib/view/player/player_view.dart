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
  int attack(int value) => _state.attack(value);
}

class _PlayerState extends BaseState<PlayerView> with BaseFrame, BaseCraft {
  final _posStream = StreamController<Offset>();
  final _showStream = StreamController<bool>();
  final _stateStream = StreamController<int>();
  final _stateViews = List<Widget>();
  final _playerH = 40.0;
  final _playerW = 30.0;

  Offset _position;
  int _hp;
  int _animState = 0;
  int _animStateNum = 0;

  /// 无敌状态
  bool _invincible = false;

  @override
  void init() {
    _hp = 3;
    _position = Offset(getScreenWidth(context) / 2 - _playerW / 2,
        getScreenHeight(context) - 80);
    _stateViews.addAll(List.generate(4, (index) {
      return Image.asset(
        "images/player_state${index + 1}.png",
        width: _playerW,
        height: _playerH,
        fit: BoxFit.fill,
      );
    }));

    bindSub(TimerUtil.renderStream.listen((_) => render()));
    bindSub(TimerUtil.updateStream.listen((_) => update()));
  }

  @override
  void dispose() {
    _posStream.close();
    _showStream.close();
    _stateStream.close();
    _stateViews.clear();

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
                        child: StreamBuilder(
                          stream: _stateStream.stream,
                          initialData: 0,
                          builder: (context, snapshot) {
                            final state = snapshot.data;

                            return _stateViews[state];
                          },
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
  void render() {
    if (_hp == null || _position == null) return;

    streamAdd(_posStream, _position);
    streamAdd(_stateStream, _animStateNum);
  }

  @override
  void update() {
    _animState++;
    if (_animState >= 60) {
      _animState = 0;
    }

    _animStateNum = _animState ~/ 15;
  }

  /// 调用该方法表示手指移动了多少像素
  void move(double xNum, double yNum) async {
    if (TimerUtil.isPause) return;

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

    // 忽略部分位置
    return Rect.fromPoints(Offset(_position.dx, _position.dy + _playerH / 8),
        Offset(_position.dx + _playerW, _position.dy + _playerH / 4 * 3));
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
  int attack(int value) {
    if (_invincible) {
      return 0;
    }

    _hp -= value;

    // 无敌状态
    if (_hp > 0) {
      _showInvincible();
    }

    return 0;
  }

  /// 显示无敌时的闪烁效果
  void _showInvincible() async {
    _invincible = true;
    await for (final show
        in Stream.fromIterable([false, true, false, true, false, true])) {
      streamAdd(_showStream, show);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    _invincible = false;
  }
}
