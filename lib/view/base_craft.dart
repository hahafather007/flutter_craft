import 'package:flutter/material.dart';

abstract class BaseCraft {
  /// 子弹发射点
  Offset getFirePos();

  /// 矩形区域
  Rect getRect();

  /// 被击中的方法
  /// 返回方法表示是游戏得分
  int attack(int value);

  /// 能付被击中
  bool get canAttack;
}
