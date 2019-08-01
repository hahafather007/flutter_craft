import 'package:flutter/material.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';

abstract class BaseBulletView extends StatefulWidget with BaseFrame {
  final BaseBulletState state = null;

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
}

abstract class BaseBulletState<T extends BaseBulletView> extends BaseState<T>
    with BaseFrame {
  double xMove;
  double yMove;
  Offset position;

  /// 获取当前的矩形区域
  Rect getRect();

  @override
  void nextFrame() {
    if (position == null || xMove == null || yMove == null) {
      return;
    }

    setState(() {
      position = Offset(position.dx + xMove, position.dy + yMove);
    });
  }
}
