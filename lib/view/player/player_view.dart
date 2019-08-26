import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/view/base_craft.dart';
import 'package:flutter_craft/common/settings.dart';

class PlayerView extends StatefulWidget with BaseCraft, BaseFrame {
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

  @override
  void reset() {
    _state.reset();
  }

  Offset getCenterPos() {
    return _state.getCenterPos();
  }

  Offset getRocketPos() {
    return _state.getRocketPos();
  }

  @override
  bool get canAttack => _state.canAttack;

  @override
  int attack(int value) => _state.attack(value);

  @override
  bool canRecycle() {
    return _state.canRecycle();
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

class _PlayerState extends BaseState<PlayerView> with BaseFrame, BaseCraft {
  final _posStream = StreamController<Offset>();
  final _showStream = StreamController<bool>();
  final _stateStream = StreamController<int>();
  final _boomStream = StreamController<int>();
  final _stateViews = List<Widget>();
  final _boomViews = List<Widget>();
  final _playerH = 40.0;
  final _playerW = 30.0;

  Offset _position;
  int _hp;
  int _animState = 0;
  int _animStateNum = 0;
  int _invincibleNum = 0;
  int _boomNum = 0;
  int _boomState = 0;

  /// 无敌状态
  bool _invincible = false;
  bool _playerShow = true;
  bool _isRocketLeft = true;
  bool _isBoom = false;

  @override
  void init() {
    _hp = Settings.playerHp;
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
    _boomViews.addAll(List.generate(6, (index) {
      return Image.asset(
        "images/boom3_state${index + 1}.png",
        width: _playerH,
        height: _playerH,
        fit: BoxFit.fill,
      );
    }));
  }

  @override
  void dispose() {
    _posStream.close();
    _showStream.close();
    _stateStream.close();
    _boomStream.close();
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
                    initialData: _playerShow,
                    builder: (context, snapshot) {
                      final show = snapshot.data;

                      return AnimatedOpacity(
                        opacity: show ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 200),
                        child: StreamBuilder(
                          stream: _stateStream.stream,
                          initialData: _animState,
                          builder: (context, snapshot) {
                            final state = snapshot.data;

                            return StreamBuilder(
                              stream: _boomStream.stream,
                              initialData: _boomState,
                              builder: (context, snapshot) {
                                final boomState = snapshot.data;

                                return _isBoom
                                    ? _boomViews[boomState]
                                    : _stateViews[state];
                              },
                            );
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
    return _hp <= 0 && _boomNum == 120;
  }

  @override
  void render() {
    if (_hp == null || _position == null) return;

    streamAdd(_posStream, _position);
    streamAdd(_stateStream, _animStateNum);
    streamAdd(_showStream, _playerShow);
    streamAdd(_boomStream, _boomState);
  }

  @override
  void update() {
    if (_isBoom) {
      _boomNum++;
      if (_boomNum < 120) {
        if (_boomNum < 60) {
          _boomState = _boomNum ~/ 10;
        } else {
          _boomState = (_boomNum - 60) ~/ 10;
        }
      }
    } else {
      _animState++;
      if (_invincible) {
        _invincibleNum++;
        _playerShow = (_invincibleNum ~/ 20) % 2 != 0;
        if (_invincibleNum > 100) {
          _invincible = false;
        }
      }
      if (_animState >= 60) {
        _animState = 0;
      }
      _animStateNum = _animState ~/ 15;
    }
  }

  /// 调用该方法表示手指移动了多少像素
  void move(double xNum, double yNum) async {
    if (_isBoom) return;

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
    if (_position == null || _isBoom) {
      return null;
    }

    return Offset(_position.dx + _playerW / 2, _position.dy);
  }

  /// 火箭弹发射位置（左边一下，右边一下）
  Offset getRocketPos() {
    if (_position == null || _isBoom) {
      return null;
    }

    _isRocketLeft = !_isRocketLeft;
    return Offset(_position.dx + _playerW / 4 * (_isRocketLeft ? 1 : 3),
        _position.dy + _playerH / 5);
  }

  Offset getCenterPos() {
    if (_position == null) {
      return null;
    }

    return Offset(_position.dx + _playerW / 2, _position.dy + _playerH / 2);
  }

  @override
  bool get canAttack => !_invincible && !_isBoom;

  @override
  int attack(int value) {
    if (_invincible || _isBoom) {
      return 1;
    }

    _hp -= value;

    // 无敌状态
    if (_hp > 0) {
      _invincible = true;
      _invincibleNum = 0;
    } else {
      _isBoom = true;
    }

    return _hp;
  }

  @override
  void reset() {
    _animState = 0;
    _animStateNum = 0;
    _invincibleNum = 0;
    _boomNum = 0;
    _boomState = 0;
    _isBoom = false;
    _stateViews.clear();
    init();
  }
}
