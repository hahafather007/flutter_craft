import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/base_craft.dart';

/// 所有敌机的基础类
abstract class BaseCraftView extends StatefulWidget with BaseFrame, BaseCraft {
  final BaseCraftState state = null;

  @override
  State<StatefulWidget> createState() => state;

  @override
  bool get canAttack {}

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
abstract class BaseCraftState<T extends BaseCraftView> extends BaseState<T>
    with BaseFrame, BaseCraft {
  final posStream = StreamController<Offset>();
  final random = Random.secure();

  int hp;
  double xMove;
  double yMove;
  Offset position;

  @override
  void dispose() {
    posStream.close();

    super.dispose();
  }

  @override
  void render() {
    if (position == null) return;

    streamAdd(posStream, position);
  }

  @override
  void update() {
    if (hp == null || position == null || xMove == null || yMove == null) {
      return;
    }
    position = Offset(position.dx + xMove, position.dy + yMove);

    if (canRecycle()) {
      init();
    }
  }
}
