import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/base_enemy.dart';
import 'package:flutter_craft/view/enemy/enemy01.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/utils/timer_util.dart';

class EnemyView extends StatefulWidget {
  final _state = _EnemyState();

  @override
  State createState() => _state;

  List<BaseEnemyView> get enemies => _state._enemies;
}

class _EnemyState extends BaseState<EnemyView> {
  final _ememyStream = StreamController<List<BaseEnemyView>>();
  final _enemies = List<BaseEnemyView>();

  int _enemy01Skip = 0;
  int _enemyIndex = 0;

  @override
  void init() {
    // 初始化每种类型的敌机
    bindSub(TimerUtil.updateStream.listen((_) async {
      _enemies.forEach((v) => v.update());
      _enemy01Skip++;

      // 回收超出屏幕的飞机
      _enemies.removeWhere((v) => v.canRecycle());

      // 生成[Enemy01]
      if (_enemy01Skip >= 30) {
        _enemy01Skip = 0;
        _enemies.add(Enemy01(
          key: Key("Enemy01${_enemyIndex++}"),
        ));
      }
    }));
    bindSub(TimerUtil.renderStream.listen((_) {
      streamAdd(_ememyStream, _enemies);
      _enemies.forEach((v) => v.render());
    }));
  }

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
}
