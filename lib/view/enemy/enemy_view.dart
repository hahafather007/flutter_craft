import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/base_craft.dart';
import 'package:flutter_craft/view/enemy/enemy01.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/utils/timer_util.dart';

class EnemyView extends StatefulWidget {
  @override
  State createState() => EnemyState();
}

class EnemyState extends BaseState<EnemyView> {
  final enemies = List<BaseCraftView>();

  @override
  void init() {
    // 初始化每种类型的敌机
    enemies.addAll(List.generate(1000, (_) => Enemy01()));

    // 每16毫秒移动一次敌机，保证60帧
    bindSub(TimerUtil.frameStream
        .listen((_) async => enemies.forEach((v) => v.nextFrame())));
  }

  @override
  void dispose() {
    enemies.clear();
    subDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: enemies,
    );
  }
}
