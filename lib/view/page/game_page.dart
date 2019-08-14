import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/enemy_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/player/player_view.dart';
import 'package:flutter_craft/view/bullet/enemy_bullet_view.dart';
import 'package:flutter_craft/view/bullet/player_bullet_view.dart';
import 'package:flutter_craft/view/background/game_ground.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class GamePage extends StatefulWidget {
  @override
  State createState() => GameState();
}

class GameState extends BaseState<GamePage> with BaseFrame {
  final _scoreStream = StreamController<int>();
  final _pool = Soundpool(maxStreams: 10);

  AudioPlayer _audioPlayer;
  EnemyView _enemyView;
  PlayerView _playerView;
  EnemyBulletView _enemyBulletView;
  PlayerBulletView _playerBulletView;

  /// 游戏得分
  int _score = 0;
  int _enemySoundId;

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

    // 敌机爆炸音效
    rootBundle.load("assets/enemy_boom01.mp3").then((data) async {
      _enemySoundId = await _pool.load(data);
      _pool.setVolume(soundId: _enemySoundId, volume: 0.2);
    });

    bindSub(TimerUtil.updateStream.listen((_) => update()));
    bindSub(TimerUtil.renderStream.listen((_) => render()));
  }

  @override
  void dispose() {
    _audioPlayer?.release();
    _pool.release();
    _scoreStream.close();

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

          // 得分
          _buildScoreView(),
        ],
      ),
    );
  }

  /// 得分视图
  Widget _buildScoreView() {
    return Positioned(
      top: getStatusHeight(context) + 30,
      left: 14,
      child: StreamBuilder(
        stream: _scoreStream.stream,
        initialData: _score,
        builder: (context, snapshot) {
          final score = snapshot.data;

          return Text(
            "得分：$score",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          );
        },
      ),
    );
  }

  @override
  bool canRecycle() {
    return false;
  }

  @override
  void update() async {
    // 检测玩家是否被击中
    if (_playerView.canAttack) {
      _enemyBulletView.bullets.forEach((bullet) {
        if (bullet.getRect() != null && _playerView.getRect() != null) {
          if (bullet.getRect().overlaps(_playerView.getRect())) {
            _playerView.attack(1);
            bullet.useBullet();
          }
        }
      });
    }

    // 检测敌机是否被击中
    _playerBulletView.bullets.forEach((bullet) {
      for (final enemy in _enemyView.enemies) {
        if (!enemy.canAttack) {
          continue;
        }

        if (bullet.getRect() != null && enemy.getRect() != null) {
          if (bullet.getRect().overlaps(enemy.getRect())) {
            final add = enemy.attack(1);
            if (add > 0) {
              _score += add;
              _pool.play(_enemySoundId);
            }
            bullet.useBullet();
            break;
          }
        }
      }
    });
  }

  @override
  void render() {
    streamAdd(_scoreStream, _score);
  }
}
