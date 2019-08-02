import 'package:flutter/material.dart';
import 'enemy_bullet01.dart';
import 'package:flutter_craft/view/enemy/base_craft.dart';
import 'package:flutter_craft/view/player/player_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'package:flutter_craft/common/settings.dart';
import 'dart:math';
import 'dart:async';

class EnemyBulletView extends StatefulWidget {
  final List<BaseCraftView> enemies;
  final PlayerView player;

  EnemyBulletView({@required this.enemies, @required this.player});

  @override
  State createState() => _EnemyBulletState();
}

class _EnemyBulletState extends BaseState<EnemyBulletView> {
  final _bulletStream = StreamController<List<EnemyBullet01>>();

  final _enemyBullets = List<EnemyBullet01>();
  final _random = Random.secure();

  int _skipNum = 0;

  @override
  void init() {
    // 创建敌机的子弹
    bindSub(TimerUtil.frameStream
        .map((_) => _skipNum++)
        .where((_) => widget.enemies.isNotEmpty)
        .listen((_) async {
      _enemyBullets.forEach((v) => v.nextFrame());

      if (_skipNum >= (Settings.IS_FRAME60 ? 10 : 5)) {
        _skipNum = 0;
        final removeIndex = List<int>();
        for (int i = 0; i < _enemyBullets.length; i++) {
          if (_enemyBullets[i].canRecycle()) {
            removeIndex.add(i);
          }
        }
        removeIndex.forEach((index) => _enemyBullets.removeAt(index));
        final index = _random.nextInt(widget.enemies.length);
        final bullet = EnemyBullet01(
            enemyPos: widget.enemies[index].getFirePos(),
            playerPos: widget.player.getCenterPos());
        _enemyBullets.add(bullet);
        streamAdd(_bulletStream, _enemyBullets);
      }
    }));
  }

  @override
  void dispose() {
    _enemyBullets.clear();
    _bulletStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bulletStream.stream,
      initialData: _enemyBullets,
      builder: (context, snapshot) {
        final bullets = snapshot.data;

        return Stack(
          children: bullets,
        );
      },
    );
  }
}
