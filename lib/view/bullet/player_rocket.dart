import 'package:flutter/material.dart';
import 'base_bullet.dart';
import 'dart:async';
import 'package:flutter_craft/common/streams.dart';
import 'package:flutter_craft/common/settings.dart';

/// 火箭弹
class PlayerRocket extends BaseBulletView {
  final _state = _PlayerRocketState();

  final Offset playerPos;

  PlayerRocket({Key key, @required this.playerPos}) : super(key: key);

  @override
  BaseBulletState<BaseBulletView> get state => _state;
}

class _PlayerRocketState extends BaseBulletState<PlayerRocket> {
  final _stateStream = StreamController<int>();
  final _bulletW = 6.0;
  final _bulletH = 30.0;
  final _rocketViews = List<Widget>();
  final _boomViews = List<Widget>();

  int _animState = 0;
  int _animNum = 0;
  bool _isBoom = false;

  @override
  void init() {
    position = Offset(widget.playerPos.dx - _bulletW / 2, widget.playerPos.dy);
    xMove = 0;
    yMove = -1;
    bulletFire = Settings.rocketAttack;

    _rocketViews.addAll(List.generate(3, (index) {
      return Image.asset(
        "images/rocket_0${index + 1}.png",
        width: _bulletW,
        height: _bulletH,
        fit: BoxFit.fill,
      );
    }));
    _boomViews.addAll(List.generate(6, (index) {
      return Image.asset(
        "images/boom2_state${index + 1}.png",
        width: _bulletW * 2.5,
        height: _bulletW * 2.5,
        fit: BoxFit.fill,
      );
    }));
  }

  @override
  void dispose() {
    _stateStream.close();
    _rocketViews.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: posStream.stream,
      initialData: position,
      builder: (context, snapshot) {
        final Offset offset = snapshot.data;

        return Positioned(
          top: offset.dy,
          left: offset.dx,
          child: StreamBuilder(
            stream: _stateStream.stream,
            initialData: _animState,
            builder: (context, snapshot) {
              final state = snapshot.data;

              if (!_isBoom) {
                if (state < 3) {
                  return _rocketViews[state];
                } else {
                  return Container();
                }
              } else {
                return _boomViews[state];
              }
            },
          ),
        );
      },
    );
  }

  @override
  bool canRecycle() {
    if (bulletUsed && !_isBoom) {
      return true;
    }

    if (position == null) {
      return false;
    }

    return position.dy < -_bulletH;
  }

  @override
  void update() {
    if (!_isBoom) {
      super.update();

      _animNum++;
      if (_animNum >= 30) {
        _animNum = 0;
      }
      _animState = _animNum ~/ 10;
      if (yMove != null && yMove > -8) {
        yMove -= 0.1;
      }
    } else {
      _animNum++;
      if (_animNum >= 60) {
        _animNum = 59;
        _isBoom = false;
      }
      _animState = _animNum ~/ 10;
    }
  }

  @override
  void render() {
    super.render();

    streamAdd(_stateStream, _animState);
  }

  @override
  void useBullet() {
    super.useBullet();

    _isBoom = true;
    _animNum = 0;
    _animState = 0;
  }

  @override
  Rect getRect() {
    if (position == null) {
      return null;
    }

    return Rect.fromPoints(position,
        Offset(position.dx + _bulletW, position.dy + _bulletH / 4 * 3));
  }
}
