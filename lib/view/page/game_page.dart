import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/enemy_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/player/player_view.dart';
import 'package:flutter_craft/view/bullet/enemy_bullet_view.dart';
import 'package:flutter_craft/utils/timer_util.dart';

class GamePage extends StatefulWidget {
  @override
  State createState() => GameState();
}

class GameState extends BaseState<GamePage> {
  EnemyView _enemyView;
  PlayerView _playerView;
  EnemyBulletView _enemyBulletView;

  @override
  void init() {
    _enemyView = EnemyView();
    _playerView = PlayerView();
    _enemyBulletView =
        EnemyBulletView(enemies: _enemyView.enemies, player: _playerView);

    // 检测玩家是否被击中
    bindSub(
        TimerUtil.frameStream.where((_) => _playerView.canAttack).listen((_) {
      for (var bullet in _enemyBulletView.bullets) {
        if (bullet.getRect() != null && _playerView.getRect() != null) {
          if (bullet.getRect().overlaps(_playerView.getRect())) {
            _playerView.attack(1);
            bullet.use();
            break;
          }
        }
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 敌机图层
          _enemyView,

          // 敌机子弹图层
          _enemyBulletView,

          // 玩家图层
          _playerView,
        ],
      ),
    );
  }
}
