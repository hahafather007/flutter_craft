import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/enemy_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/gift/bullet_gift.dart';
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
import 'package:flutter_craft/view/gift/gift_view.dart';

class GamePage extends StatefulWidget {
  @override
  State createState() => GameState();
}

class GameState extends BaseState<GamePage>
    with BaseFrame, WidgetsBindingObserver {
  final _pauseStream = StreamController<bool>();
  final _overStream = StreamController<bool>();
  final _scoreStream = StreamController<int>();
  final _rocketStream = StreamController<int>();
  final _playerHpStream = StreamController<int>();
  final _pool = Soundpool(maxStreams: 10);

  AudioPlayer _audioPlayer;
  EnemyView _enemyView;
  PlayerView _playerView;
  EnemyBulletView _enemyBulletView;
  PlayerBulletView _playerBulletView;
  GameGround _gameGround;
  GiftView _giftView;

  /// 游戏得分
  int _score = 0;

  /// 敌机爆炸音效
  int _enemySoundId;

  /// 玩家爆炸音效
  int _playerSoundId;

  /// 是否暂停
  bool _isPause = false;

  /// 游戏是否结束
  bool _isGameOver = false;

  /// 火箭弹数量
  int _rocketNum;

  @override
  void init() {
    _gameGround = GameGround();
    _enemyView = EnemyView();
    _playerView = PlayerView();
    _giftView = GiftView();
    _enemyBulletView =
        EnemyBulletView(enemies: _enemyView.enemies, player: _playerView);
    _playerBulletView = PlayerBulletView(player: _playerView);

    _rocketNum = _playerBulletView.rocketNum;
    // bgm
    final audio = AudioCache();
    audio.loop("game_bg.mp3").then((v) => _audioPlayer = v);

    // 敌机爆炸音效
    rootBundle.load("assets/enemy_boom01.mp3").then((data) async {
      _enemySoundId = await _pool.load(data);
      _pool.setVolume(soundId: _enemySoundId, volume: 0.2);
    });

    // 玩家爆炸音效
    rootBundle.load("assets/player_boom.mp3").then((data) async {
      _playerSoundId = await _pool.load(data);
      _pool.setVolume(soundId: _playerSoundId, volume: 1);
    });

    bindSub(TimerUtil.updateStream
        .where((_) => !_isPause && !_isGameOver)
        .listen((_) => update()));
    bindSub(TimerUtil.renderStream
        .where((_) => !_isPause && !_isGameOver)
        .listen((_) => render()));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _audioPlayer?.release();
    _pool.release();
    _scoreStream.close();
    _pauseStream.close();
    _overStream.close();
    _rocketStream.close();
    _playerHpStream.close();
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
    return WillPopScope(
      child: Scaffold(
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

            // 奖励品
            _giftView,

            // 玩家图层
            _playerView,

            // 火箭弹按钮
            _buildRocketBtn(),

            // 生命值
            _buildHpView(),

            // 暂停
            _buildPauseView(),

            // 得分
            _buildScoreView(),

            // 游戏结束
            _buildGameOver(),
          ],
        ),
      ),
      onWillPop: () async {
        if (!_isPause && !_isGameOver) {
          _pause();
        }

        return false;
      },
    );
  }

  /// 玩家血量的指示
  Widget _buildHpView() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 14,
      child: StreamBuilder(
        stream: _playerHpStream.stream,
        initialData: Settings.playerHp,
        builder: (context, snapshot) {
          final hp = snapshot.data;
          Color color;
          if (hp > Settings.playerHp * 3 / 4) {
            color = Colors.green;
          } else if (hp > Settings.playerHp >> 1) {
            color = Colors.yellow;
          } else if (hp > Settings.playerHp >> 2) {
            color = Colors.orange;
          } else {
            color = Colors.red;
          }

          return Center(
            child: Opacity(
              opacity: 0.5,
              child: Container(
                height: 160,
                width: 10,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: AnimatedContainer(
                  color: color,
                  width: 10,
                  height: 160 * hp / Settings.playerHp,
                  duration: const Duration(milliseconds: 300),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 游戏结束界面
  Widget _buildGameOver() {
    return StreamBuilder(
      stream: _overStream.stream,
      initialData: _isGameOver,
      builder: (context, snapshot) {
        final isOver = snapshot.data;

        return isOver
            ? Container(
                color: Colors.black45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "GameOver!",
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white70,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 8),
                      child: Text(
                        "得分：$_score",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildMenuBtn(),
                  ],
                ),
              )
            : Container();
      },
    );
  }

  /// 暂停按钮及视图
  Widget _buildPauseView() {
    return StreamBuilder(
      stream: _pauseStream.stream,
      initialData: _isPause,
      builder: (context, snapshot) {
        final isPause = snapshot.data;

        return Container(
          color: isPause ? Colors.black45 : null,
          child: Stack(
            children: <Widget>[
              // 暂停
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

              // 暂停菜单
              Center(
                child: isPause
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              "暂停中",
                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          _buildMenuBtn(),
                        ],
                      )
                    : Container(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 菜单界面的按钮
  Widget _buildMenuBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () => pop(context),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.asset(
                "images/btn.png",
                width: 80,
                height: 40,
                fit: BoxFit.fill,
              ),
              Text(
                "退到主页",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(width: 24),
        GestureDetector(
          onTap: reset,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.asset(
                "images/btn.png",
                width: 80,
                height: 40,
                fit: BoxFit.fill,
              ),
              Text(
                "重新开始",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
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
    _giftView.update();

    _rocketNum = _playerBulletView.rocketNum;
    // 检测玩家是否被击中
    if (_playerView.canAttack) {
      for (final bullet in _enemyBulletView.bullets) {
        if (bullet.getRect() != null && _playerView.getRect() != null) {
          if (bullet.getRect().overlaps(_playerView.getRect())) {
            final score = _playerView.attack(bullet.bulletFire);
            bullet.useBullet();
            if (score == 0) {
              _pool.play(_playerSoundId);
            }

            break;
          }
        }
      }
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
              _giftView.createGift(enemy.getCenter());
              _pool.play(_enemySoundId);
            }
            bullet.useBullet();
            break;
          }
        }
      }
    });

    // 检测玩家是否和敌机相撞
    if (_playerView.canAttack) {
      for (final enemy in _enemyView.enemies) {
        if (enemy.getRect() != null && enemy.getRect() != null) {
          if (enemy.getRect().overlaps(_playerView.getRect())) {
            final add = enemy.attack(3);
            if (add > 0) {
              _score += add;
              _pool.play(_enemySoundId);
            }
            _playerView.attack(1);
            break;
          }
        }
      }
    }

    // 检测是否吃到了奖励
    _giftView.gifts.forEach((gift) {
      if (!gift.canRecycle()) {
        if (gift.getRect() != null && _playerView.getRect() != null) {
          if (gift.getRect().overlaps(_playerView.getRect())) {
            if (gift is BulletGift) {
              _playerBulletView.ateBullet();
            } else {
              _playerBulletView.ateRocket();
            }
            gift.useGift();
          }
        }
      }
    });

    // 检测游戏是否结束
    if (_playerView.canRecycle()) {
      _gameOver();
    }
  }

  void _gameOver() {
    _isGameOver = true;
    _audioPlayer?.pause();
    streamAdd(_overStream, true);
  }

  void _pause() {
    _isPause = true;
    _audioPlayer?.pause();
    streamAdd(_pauseStream, true);
  }

  void _resume() {
    _isPause = false;
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
    _giftView.render();

    streamAdd(_scoreStream, _score);
    streamAdd(_rocketStream, _rocketNum);
    streamAdd(_playerHpStream, _playerView.hp);
  }

  @override
  void reset() {
    _gameGround.reset();
    _playerView.reset();
    _playerBulletView.reset();
    _enemyView.reset();
    _enemyBulletView.reset();
    _giftView.reset();
    _score = 0;
    _rocketNum = _playerBulletView.rocketNum;
    _isGameOver = false;
    _audioPlayer.seek(const Duration());
    streamAdd(_overStream, false);
    _resume();
  }
}
