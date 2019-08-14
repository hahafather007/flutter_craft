import 'package:flutter/material.dart';
import 'enemy_bullet01.dart';
import 'base_bullet.dart';
import 'package:flutter_craft/view/enemy/base_enemy.dart';
import 'package:flutter_craft/view/player/player_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'dart:math';
import 'dart:async';

class EnemyBulletView extends StatefulWidget {
  final _state = _EnemyBulletState();

  final List<BaseEnemyView> enemies;
  final PlayerView player;

  EnemyBulletView({@required this.enemies, @required this.player});

  @override
  State createState() => _state;

  List<BaseBulletView> get bullets => _state._bullets;
}

class _EnemyBulletState extends BaseState<EnemyBulletView> {
  final _bulletStream = StreamController<List<BaseBulletView>>();
  final _bullets = List<BaseBulletView>();
  final _random = Random.secure();

  int _skipNum = 0;
  int _bulletIndex = 0;

  @override
  void init() {
    // 创建敌机的子弹
    bindSub(TimerUtil.updateStream
        .map((_) => _skipNum++)
        .where((_) => widget.enemies.isNotEmpty)
        .listen((_) async {
      _bullets.forEach((v) => v.update());

      // 清理可回收的子弹
      _bullets.removeWhere((v) => v.canRecycle());

      // 随机让敌机发射子弹
      if (_skipNum >= 10) {
        _skipNum = 0;
        final index = _random.nextInt(widget.enemies.length);
        final bullet = EnemyBullet01(
            key: Key("EnemyBullet01${_bulletIndex++}"),
            enemyPos: widget.enemies[index].getFirePos(),
            playerPos: widget.player.getCenterPos());
        _bullets.add(bullet);
      }
    }));

    // 绘制每一帧
    bindSub(TimerUtil.renderStream.listen((_) {
      streamAdd(_bulletStream, _bullets);
      _bullets.forEach((v) => v.render());
    }));
  }

  @override
  void dispose() {
    _bullets.clear();
    _bulletStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bulletStream.stream,
      initialData: _bullets,
      builder: (context, snapshot) {
        final bullets = snapshot.data;

        return Stack(
          children: bullets,
        );
      },
    );
  }
}
