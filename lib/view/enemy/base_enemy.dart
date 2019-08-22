import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/base_craft.dart';

/// 所有敌机的基础类
abstract class BaseEnemyView extends StatefulWidget with BaseFrame, BaseCraft {
  final BaseCraftState state = null;

  BaseEnemyView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => state;

  @override
  bool get canAttack;

  @override
  void reset() {
    state.reset();
  }

  @override
  void render() {
    state.render();
  }

  @override
  void update() {
    state.update();
  }

  @override
  bool canRecycle() {
    return state.canRecycle();
  }

  @override
  Offset getFirePos() {
    return state.getFirePos();
  }

  @override
  Rect getRect() {
    return state.getRect();
  }
}

/// 所有敌机的基础类
abstract class BaseCraftState<T extends BaseEnemyView> extends BaseState<T>
    with BaseFrame, BaseCraft {
  final posStream = StreamController<Offset>();
  final boomStateStream = StreamController<int>();
  final random = Random.secure();

  int hp = 1;

  int _boomState;
  int _boomStateNum;
  bool isBoom = false;
  double xMove;
  double yMove;
  Offset position;
  List<Widget> boomViews;

  @override
  void dispose() {
    posStream.close();
    boomStateStream.close();
    boomViews.clear();

    super.dispose();
  }

  @override
  void init() {
    _boomState = 0;
    _boomStateNum = 0;
    isBoom = false;
  }

  @override
  void render() {
    if (position == null) return;

    streamAdd(posStream, position);
    streamAdd(boomStateStream, _boomStateNum);
  }

  @override
  void update() {
    if (hp == null || position == null || xMove == null || yMove == null) {
      return;
    }
    if (!isBoom) {
      position = Offset(position.dx + xMove, position.dy + yMove);
    }

    if (isBoom && boomViews?.isNotEmpty == true) {
      _boomState++;
      if (_boomState >= 40) {
        isBoom = false;
      } else {
        _boomStateNum = _boomState ~/ 10;
      }
    }
  }

  @override
  void reset() {}
}
