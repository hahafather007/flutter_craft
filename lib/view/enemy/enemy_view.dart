import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/base_enemy.dart';
import 'package:flutter_craft/view/enemy/enemy01.dart';
import 'package:flutter_craft/view/enemy/enemy02.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'dart:math';

class EnemyView extends StatefulWidget with BaseFrame {
  final _state = _EnemyState();

  @override
  State createState() => _state;

  List<BaseEnemyView> get enemies => _state._enemies;

  @override
  void reset() {
    _state.reset();
  }

  @override
  bool canRecycle() {
    return _state.canRecycle();
  }

  @override
  void update() {
    _state.update();
  }

  @override
  void render() {
    _state.render();
  }
}

class _EnemyState extends BaseState<EnemyView> with BaseFrame {
  final _ememyStream = StreamController<List<BaseEnemyView>>();
  final _enemies = List<BaseEnemyView>();
  final _random = Random.secure();

  int _enemy01Skip = 0;
  int _enemy02Skip = 0;
  int _enemy02Num = 0;
  int _enemy02Create = 0;
  int _enemy02Type;
  int _enemyIndex = 0;

  @override
  void init() {}

  @override
  void dispose() {
    _enemies.clear();
    _ememyStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _ememyStream.stream,
      initialData: _enemies,
      builder: (context, snapshot) {
        final enemies = snapshot.data;

        return Stack(
          children: enemies,
        );
      },
    );
  }

  @override
  bool canRecycle() {
    return false;
  }

  @override
  void update() async {
    _enemies.forEach((v) => v.update());
    _enemy01Skip++;
    _enemy02Skip++;

    // 回收超出屏幕的飞机
    _enemies.removeWhere((v) => v.canRecycle());

    // 生成[Enemy01]
    if (_enemy01Skip >= 30) {
      _enemy01Skip = 0;
      _enemies.add(Enemy01(
        key: Key("Enemy01${_enemyIndex++}"),
      ));
    }
    // 生成[Enemy00]
    if (_enemy02Skip >= 100) {
      if (_enemy02Type == null) {
        _enemy02Type = _random.nextInt(7);
      }
      if (_enemy02Num >= 10) {
        _enemy02Skip = 0;
        _enemy02Num = 0;
        _enemy02Create = 0;
        _enemy02Type = null;
      } else {
        _enemy02Create++;

        if (_enemy02Create >= 10) {
          _enemy02Num++;
          _enemy02Create = 0;
          _enemies.add(Enemy02(
            type: _enemy02Type,
            key: Key("Enemy02${_enemyIndex++}"),
          ));
        }
      }
    }
  }

  @override
  void render() {
    streamAdd(_ememyStream, _enemies);
    _enemies.forEach((v) => v.render());
  }

  @override
  void reset() {
    _enemy01Skip = 0;
    _enemy02Skip = 0;
    _enemy02Num = 0;
    _enemy02Create = 0;
    _enemy02Type = null;
    _enemyIndex = 0;
    _enemies.clear();
  }
}
