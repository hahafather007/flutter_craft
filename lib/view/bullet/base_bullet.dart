import 'package:flutter/material.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'dart:async';

abstract class BaseBulletView extends StatefulWidget with BaseFrame {
  final BaseBulletState state = null;

  BaseBulletView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => state;

  Rect getRect() {
    return state.getRect();
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

  /// 子弹的伤害
  int get bulletFire => state.bulletFire;

  void useBullet() => state.useBullet();
}

abstract class BaseBulletState<T extends BaseBulletView> extends BaseState<T>
    with BaseFrame {
  final posStream = StreamController<Offset>();

  bool bulletUsed = false;
  double xMove;
  double yMove;
  Offset position;
  int bulletFire = 1;

  /// 获取当前的矩形区域
  Rect getRect();

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
    if (bulletUsed || position == null || xMove == null || yMove == null) {
      return;
    }
    position = Offset(position.dx + xMove, position.dy + yMove);
  }

  /// 子弹击中后调用
  void useBullet() {
    bulletUsed = true;
  }
}
