import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';

/// 所有敌机的基础类
abstract class BaseCraftView extends StatefulWidget with BaseFrame {
  final BaseCraftState state = null;

  @override
  State<StatefulWidget> createState() => state;

  bool attack(int value) => state.attack(value);

  @override
  void nextFrame() {
    state.nextFrame();
  }

  @override
  bool canRecycle() {
    return state.canRecycle();
  }

  Offset getFirePos() {
    return state.getFirePos();
  }

  Rect getRect() {
    return state.getRect();
  }
}

/// 所有敌机的基础类
abstract class BaseCraftState<T extends BaseCraftView> extends BaseState<T>
    with BaseFrame {
  final random = Random.secure();

  int hp;
  double xMove;
  double yMove;
  Offset position;

  /// 被击中的方法
  /// 返回值表示是否扑街
  bool attack(int value) {
    hp -= value;

    return hp <= 0;
  }

  @override
  void nextFrame() {
    if (hp == null || position == null || xMove == null || yMove == null) {
      return;
    }

    setState(() {
      position = Offset(position.dx + xMove, position.dy + yMove);
    });
    if (canRecycle()) {
      init();
    }
  }

  /// 子弹发射点
  Offset getFirePos();

  /// 矩形区域
  Rect getRect();
}
