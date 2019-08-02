import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/base_enemy.dart';
import 'package:flutter_craft/view/enemy/enemy01.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/utils/timer_util.dart';

class EnemyView extends StatefulWidget {
  final _state = _EnemyState();

  @override
  State createState() => _state;

  List<BaseCraftView> get enemies => _state._enemies;
}

class _EnemyState extends BaseState<EnemyView> {
  final _enemies = List<BaseCraftView>();

  @override
  void init() {
    // 初始化每种类型的敌机
    _enemies.addAll(List.generate(20, (_) => Enemy01()));

    bindSub(TimerUtil.frameStream
        .listen((_) async => _enemies.forEach((v) => v.nextFrame())));
  }

  @override
  void dispose() {
    _enemies.clear();
    subDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _enemies,
    );
  }
}
