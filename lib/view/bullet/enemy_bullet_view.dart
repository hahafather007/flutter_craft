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
  int _bulletIndex = 0;

  @override
  void init() {
    // 创建敌机的子弹
    bindSub(TimerUtil.frameStream
        .map((_) => _skipNum++)
        .where((_) => _skipNum >= (Settings.IS_FRAME60 ? 2 : 1))
        .where((_) => widget.enemies.isNotEmpty)
        .map((_) => _skipNum = 0)
        .listen((_) async {
      final removeList = _enemyBullets.where((v) => v.canRecycle()).toList();
      removeList
          .forEach((a) => _enemyBullets.removeWhere((b) => a.key == b.key));
      removeList.clear();
      final index = _random.nextInt(widget.enemies.length);
      final bullet = EnemyBullet01(
          key: Key("EnemyBullet01${_bulletIndex++}"),
          enemyPos: widget.enemies[index].getFirePos(),
          playerPos: widget.player.getCenterPos());
      _enemyBullets.add(bullet);
      streamAdd(_bulletStream, _enemyBullets);
    }));

    // 控制每一帧移动
    bindSub(TimerUtil.frameStream
        .listen((_) => _enemyBullets.forEach((v) => v.nextFrame())));
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
