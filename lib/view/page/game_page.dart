import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/enemy_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/player/player_view.dart';
import 'package:flutter_craft/view/bullet/enemy_bullet_view.dart';
import 'package:flutter_craft/view/bullet/player_bullet_view.dart';
import 'package:flutter_craft/view/background/game_ground.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class GamePage extends StatefulWidget {
  @override
  State createState() => GameState();
}

class GameState extends BaseState<GamePage> {
  AudioPlayer _audioPlayer;
  EnemyView _enemyView;
  PlayerView _playerView;
  EnemyBulletView _enemyBulletView;
  PlayerBulletView _playerBulletView;

  @override
  void init() {
    _enemyView = EnemyView();
    _playerView = PlayerView();
    _enemyBulletView =
        EnemyBulletView(enemies: _enemyView.enemies, player: _playerView);
    _playerBulletView = PlayerBulletView(player: _playerView);

    // bgm
    final audio = AudioCache();
    audio.loop("game_bg.mp3").then((v) => _audioPlayer = v);

    // 检测玩家是否被击中
    bindSub(TimerUtil.updateStream
        .where((_) => _playerView.canAttack)
        .listen((_) async {
      _enemyBulletView.bullets.forEach((bullet) {
        if (bullet.getRect() != null && _playerView.getRect() != null) {
          if (bullet.getRect().overlaps(_playerView.getRect())) {
            _playerView.attack(1);
            bullet.useBullet();
          }
        }
      });
//      _playerBulletView.bullets.forEach((bullet){
//
//      });
    }));
  }

  @override
  void dispose() {
    _audioPlayer?.release();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 背景
          GameGround(),

          // 敌机子弹图层
          _enemyBulletView,

          // 玩家子弹图层
          _playerBulletView,

          // 敌机图层
          _enemyView,

          // 玩家图层
          _playerView,
        ],
      ),
    );
  }
}
