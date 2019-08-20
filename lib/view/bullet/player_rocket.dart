import 'package:flutter/material.dart';
import 'base_bullet.dart';
import 'dart:async';
import 'package:flutter_craft/common/streams.dart';

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
  final _bulletW = 8.0;
  final _bulletH = 37.0;
  final _rocketViews = List<Widget>();

  int _animState = 0;
  int _animNum = 0;

  @override
  void init() {
    position = Offset(widget.playerPos.dx - _bulletW / 2, widget.playerPos.dy);
    xMove = 0;
    yMove = -1;
    bulletFire = 10;

    _rocketViews.addAll(List.generate(3, (index) {
      return Image.asset(
        "images/rocket_0${index + 1}.png",
        width: _bulletW,
        height: _bulletH,
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
              return _rocketViews[state];
            },
          ),
        );
      },
    );
  }

  @override
  bool canRecycle() {
    if (bulletUsed) {
      return true;
    }

    if (position == null) {
      return false;
    }

    return position.dy < -_bulletH;
  }

  @override
  void update() {
    super.update();

    _animNum++;
    if (_animNum >= 30) {
      _animNum = 0;
    }
    _animState = _animNum ~/ 10;
    if (yMove != null && yMove > -8) {
      yMove -= 0.1;
    }
  }

  @override
  void render() {
    super.render();

    streamAdd(_stateStream, _animState);
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
