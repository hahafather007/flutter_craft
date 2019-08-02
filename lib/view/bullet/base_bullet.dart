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
  void nextFrame() {
    state.nextFrame();
  }

  @override
  bool canRecycle() {
    return state.canRecycle();
  }

  void use() => state.use();
}

abstract class BaseBulletState<T extends BaseBulletView> extends BaseState<T>
    with BaseFrame {
  final posStream = StreamController<Offset>();

  bool alreadyUse = false;
  double xMove;
  double yMove;
  Offset position;

  /// 获取当前的矩形区域
  Rect getRect();

  @override
  void dispose() {
    posStream.close();

    super.dispose();
  }

  @override
  void nextFrame() {
    if (alreadyUse || position == null || xMove == null || yMove == null) {
      return;
    }
    position = Offset(position.dx + xMove, position.dy + yMove);
    streamAdd(posStream, position);
  }

  /// 子弹击中后调用
  void use();
}
