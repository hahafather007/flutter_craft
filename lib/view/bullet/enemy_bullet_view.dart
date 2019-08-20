import 'package:flutter/material.dart';
import 'enemy_bullet01.dart';
import 'base_bullet.dart';
import 'package:flutter_craft/view/enemy/base_enemy.dart';
import 'package:flutter_craft/view/player/player_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/enemy/enemy01.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'dart:math';

class EnemyBulletView extends StatefulWidget with BaseFrame {
  final _state = _EnemyBulletState();

  final List<BaseEnemyView> enemies;
  final PlayerView player;

  EnemyBulletView({@required this.enemies, @required this.player});

  @override
  State createState() => _state;

  List<BaseBulletView> get bullets => _state._bullets;

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

class _EnemyBulletState extends BaseState<EnemyBulletView> with BaseFrame {
  final _bulletStream = StreamController<List<BaseBulletView>>();
  final _bullets = List<BaseBulletView>();
  final _random = Random.secure();

  int _enemy01Skip = 0;
  int _bulletIndex = 0;

  @override
  void init() {}

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

  @override
  bool canRecycle() {
    return false;
  }

  @override
  void update() {
    _bullets.forEach((v) => v.update());
    _enemy01Skip++;

    // 清理可回收的子弹
    _bullets.removeWhere((v) => v.canRecycle());

    // 随机让敌机发射子弹
    if (_enemy01Skip >= 20) {
      final enemy01List = widget.enemies.where((v) => v is Enemy01);
      if (enemy01List.isNotEmpty) {
        final index = _random.nextInt(enemy01List.length);
        if (widget.enemies[index].getFirePos() != null &&
            widget.player.getCenterPos() != null) {
          _enemy01Skip = 0;
          _bullets.add(EnemyBullet01(
            key: Key("EnemyBullet01${_bulletIndex++}"),
            enemyPos: widget.enemies[index].getFirePos(),
            playerPos: widget.player.getCenterPos(),
          ));
        }
      }
    }
  }

  @override
  void render() {
    streamAdd(_bulletStream, _bullets);
    _bullets.forEach((v) => v.render());
  }
}
