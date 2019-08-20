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
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'package:flutter_craft/common/settings.dart';

class GamePage extends StatefulWidget {
  @override
  State createState() => GameState();
}

class GameState extends BaseState<GamePage>
    with BaseFrame, WidgetsBindingObserver {
  final _pauseStream = StreamController<bool>();
  final _scoreStream = StreamController<int>();
  final _rocketStream = StreamController<int>();
  final _pool = Soundpool(maxStreams: 10);

  AudioPlayer _audioPlayer;
  EnemyView _enemyView;
  PlayerView _playerView;
  EnemyBulletView _enemyBulletView;
  PlayerBulletView _playerBulletView;
  GameGround _gameGround;

  /// 游戏得分
  int _score = 0;

  /// 火箭弹数量
  int _rocketNum = Settings.rocketNum;

  /// 敌机爆炸音效
  int _enemySoundId;

  @override
  void init() {
    _gameGround = GameGround();
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _audioPlayer?.release();
    _pool.release();
    _scoreStream.close();
    _pauseStream.close();
    _rocketStream.close();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 背景
          _gameGround,

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

          // 暂停
          _buildPauseView(),

          // 火箭弹按钮
          _buildRocketBtn(),
        ],
      ),
    );
  }

  /// 暂停按钮及视图
  Widget _buildPauseView() {
    return StreamBuilder(
      stream: _pauseStream.stream,
      initialData: false,
      builder: (context, snapshot) {
        final isPause = snapshot.data;

        return Stack(
          children: <Widget>[
            Positioned(
              top: getStatusHeight(context) + 28,
              right: 14,
              child: GestureDetector(
                onTap: () {
                  if (isPause) {
                    _resume();
                  } else {
                    _pause();
                  }
                },
                child: Icon(
                  isPause ? Icons.play_arrow : Icons.pause,
                  size: 32,
                  color: Colors.white70,
                ),
              ),
            ),
            Center(
              child: isPause
                  ? Text(
                      "暂停中",
                      style: TextStyle(fontSize: 36, color: Colors.white70),
                    )
                  : Container(),
            ),
          ],
        );
      },
    );
  }

  /// 火箭弹按钮
  Widget _buildRocketBtn() {
    return Positioned(
      bottom: 40,
      left: 14,
      child: StreamBuilder(
        stream: _rocketStream.stream,
        initialData: _rocketNum,
        builder: (context, snapshot) {
          final num = snapshot.data;

          return GestureDetector(
            onTap: () {
              if (num > 0) {
                _playerBulletView.fireRocket();
                _rocketNum -- ;
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset(
                  "images/rocket_btn.png",
                  width: 48,
                  height: 48,
                ),
                Text(
                  "$num",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
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
              fontSize: 16,
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
    _playerView.update();
    _playerBulletView.update();
    _enemyView.update();
    _enemyBulletView.update();
    _gameGround.update();

    // 检测玩家是否被击中
    if (_playerView.canAttack) {
      _enemyBulletView.bullets.forEach((bullet) {
        if (bullet.getRect() != null && _playerView.getRect() != null) {
          if (bullet.getRect().overlaps(_playerView.getRect())) {
            _playerView.attack(bullet.bulletFire);
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
            final add = enemy.attack(bullet.bulletFire);
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

  void _pause() {
    TimerUtil.pause();
    _audioPlayer?.pause();
    streamAdd(_pauseStream, true);
  }

  void _resume() {
    TimerUtil.resume();
    _audioPlayer?.resume();
    streamAdd(_pauseStream, false);
  }

  @override
  void render() {
    _gameGround.render();
    _playerView.render();
    _playerBulletView.render();
    _enemyView.render();
    _enemyBulletView.render();

    streamAdd(_scoreStream, _score);
    streamAdd(_rocketStream, _rocketNum);
  }
}
