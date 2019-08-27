import 'package:flutter/material.dart';
import 'base_enemy.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/common/streams.dart';
import 'dart:async';
import 'dart:math';

class Enemy02 extends BaseEnemyView {
  /// [0,1,2,3,4,5,6,7]表示8种出现方式
  final int type;
  final _state = _Enemy02State();

  Enemy02({Key key, @required this.type}) : super(key: key);

  @override
  BaseCraftState<BaseEnemyView> get state => _state;
}

class _Enemy02State extends BaseCraftState<Enemy02> {
  final _angleStream = StreamController<double>();
  final _enemyW = 30.0;
  final _enemyH = 21.0;
  final _speed = 3.0;

  double _angle = 0;
  double _angleChange = 0;
  Widget _enemyView;

  @override
  void dispose() {
    _angleStream.close();

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
          left: offset.dx,
          top: offset.dy,
          child: StreamBuilder(
            stream: boomStateStream.stream,
            initialData: 0,
            builder: (context, snapshot) {
              final state = snapshot.data;

              return !isBoom && hp > 0
                  ? StreamBuilder(
                      stream: _angleStream.stream,
                      initialData: _angle,
                      builder: (context, snapshot) {
                        final angle = snapshot.data;

                        return Transform.rotate(
                          alignment: Alignment.center,
                          angle: angle,
                          child: _enemyView,
                        );
                      },
                    )
                  : boomViews[state];
            },
          ),
        );
      },
    );
  }

  @override
  void init() {
    super.init();

    hp = 2;
    switch (widget.type) {
      case 0:
        position = Offset(-_enemyW, -_enemyH);
        _angle = -pi / 10;
        _angleChange = -0.005;
        break;
      case 1:
        position = Offset(getScreenWidth(context), -_enemyH);
        _angle = pi / 10;
        _angleChange = 0.005;
        break;
      case 2:
        position = Offset(-_enemyW, getScreenHeight(context) / 4);
        _angle = -pi / 6;
        _angleChange = -0.008;
        break;
      case 3:
        position =
            Offset(getScreenWidth(context), getScreenHeight(context) / 4);
        _angle = pi / 6;
        _angleChange = 0.008;
        break;
      case 4:
        position = Offset(-_enemyW, getScreenHeight(context) / 5);
        _angle = -pi / 4;
        _angleChange = -0.012;
        break;
      case 5:
        position =
            Offset(getScreenWidth(context), getScreenHeight(context) / 5);
        _angle = pi / 4;
        _angleChange = 0.012;
        break;
      case 6:
        position = Offset(-_enemyW, getScreenHeight(context) / 4);
        _angle = -pi / 4;
        _angleChange = -0.02;
        break;
      case 7:
        position =
            Offset(getScreenWidth(context), getScreenHeight(context) / 4);
        _angle = pi / 4;
        _angleChange = 0.02;
        break;
    }
    _calculateMove();
    boomViews = List.generate(4, (index) {
      return Image.asset(
        "images/boom_state${index + 1}.png",
        width: _enemyW,
        height: _enemyW,
        fit: BoxFit.fill,
      );
    });

    _enemyView = Image.asset(
      "images/enemy02.png",
      width: _enemyW,
      height: _enemyH,
      fit: BoxFit.fill,
    );
  }

  @override
  bool canRecycle() {
    if (position == null || isBoom) {
      return false;
    }

    return hp <= 0 ||
        position.dy >= getScreenHeight(context) ||
        position.dx < -_enemyW ||
        position.dx > getScreenWidth(context);
  }

  @override
  Rect getRect() {
    if (position == null) {
      return null;
    }

    return Rect.fromPoints(Offset(position.dx, position.dy + _enemyH / 8),
        Offset(position.dx + _enemyW, position.dy + _enemyH / 5 * 4));
  }

  @override
  void update() {
    super.update();

    if (!isBoom && widget != null) {
      _calculateMove();
    }
  }

  /// 计算坐标移动值
  void _calculateMove() {
    _angle += _angleChange;
    xMove = -_speed * sin(_angle);
    yMove = _speed * cos(_angle);
  }

  @override
  void render() {
    super.render();

    streamAdd(_angleStream, _angle);
  }

  @override
  Offset getFirePos() {
    if (position == null || isBoom) {
      return null;
    }

    return Offset(position.dx + _enemyW / 2, position.dy + _enemyH);
  }

  @override
  int attack(int value) {
    hp -= value;

    if (hp <= 0) {
      isBoom = true;

      return 1;
    }

    return 0;
  }

  @override
  bool get canAttack => hp > 0;

  @override
  Offset getCenter() {
    return Offset(position.dx + _enemyW / 2, position.dy + _enemyH / 2);
  }
}
