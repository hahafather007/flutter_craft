import 'package:flutter/material.dart';
import 'base_bullet.dart';
import 'player_bullet01.dart';
import 'player_bullet02.dart';
import 'player_bullet03.dart';
import 'package:flutter_craft/view/player/player_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/common/settings.dart';
import 'package:flutter_craft/view/bullet/player_rocket.dart';

class PlayerBulletView extends StatefulWidget with BaseFrame {
  final _state = _PlayerBulletState();

  final PlayerView player;

  PlayerBulletView({@required this.player});

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
  void reset() {
    _state.reset();
  }

  @override
  void render() {
    _state.render();
  }

  void fireRocket() {
    _state.fireRocket();
  }

  void ateBullet() {
    _state.ateBullet();
  }

  void ateRocket() {
    _state.ateRocket();
  }

  int get rocketNum => _state._rocketNum;
}

class _PlayerBulletState extends BaseState<PlayerBulletView> with BaseFrame {
  final _bulletStream = StreamController<List<BaseBulletView>>();
  final _bullets = List<BaseBulletView>();
  final _pool = Soundpool(maxStreams: 10);

  int _skipNum = 0;
  int _bulletIndex = 0;
  int _bulletSoundId;
  int _rocketSoundId;

  /// 玩家火力
  int _playerFire = Settings.playerFire;

  /// 火箭弹数量
  int _rocketNum = Settings.rocketNum;

  @override
  void init() {
    // 玩家子弹发射音效
    rootBundle.load("assets/player_bullet.wav").then((data) async {
      _bulletSoundId = await _pool.load(data);
      _pool.setVolume(soundId: _bulletSoundId, volume: 0.1);
    });

    // 火箭弹发射音效
    rootBundle.load("assets/player_rocket.mp3").then((data) async {
      _rocketSoundId = await _pool.load(data);
      _pool.setVolume(soundId: _rocketSoundId, volume: 0.5);
    });
  }

  @override
  void dispose() {
    _bullets.clear();
    _bulletStream.close();
    _pool.release();

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
    _skipNum++;
    _bullets.forEach((v) => v.update());

    // 清理可回收的子弹
    _bullets.removeWhere((v) => v.canRecycle());

    // 发射子弹
    if (_skipNum >= _playerFire && widget.player.getFirePos() != null) {
      _skipNum = 0;
      switch (Settings.playShootMood) {
        case PlayShootMood.SINGLE:
          _bullets.add(PlayerBullet01(
            key: Key("PlayerBullet01${_bulletIndex++}"),
            playerPos: widget.player.getFirePos(),
          ));
          break;
        case PlayShootMood.DOUBLE:
          _bullets.add(PlayerBullet02(
            key: Key("PlayerBullet02${_bulletIndex++}"),
            playerPos: widget.player.getFirePos(),
          ));
          break;
        case PlayShootMood.TREBLE:
          [-1, 0, 1].forEach((index) {
            final bullet = PlayerBullet03(
              key: Key("PlayerBullet03${_bulletIndex++}"),
              playerPos: widget.player.getFirePos(),
              bulletType: index,
            );
            _bullets.add(bullet);
          });
          break;
      }
      if (_bulletSoundId != null) {
        _pool.play(_bulletSoundId);
      }
    }
  }

  /// 发射火箭弹
  void fireRocket() {
    if (_rocketNum <= 0) return;

    final pos = widget.player.getRocketPos();
    if (pos == null) return;

    _bullets.add(PlayerRocket(
      key: Key("PlayerRocket${_bulletIndex++}"),
      playerPos: pos,
    ));
    if (_rocketSoundId != null) {
      _pool.play(_rocketSoundId);
    }
    _rocketNum--;
  }

  @override
  void render() {
    streamAdd(_bulletStream, _bullets);
    _bullets.forEach((v) => v.render());
  }

  @override
  void reset() {
    _skipNum = 0;
    _bullets.clear();
    _playerFire = Settings.playerFire;
    _rocketNum = Settings.rocketNum;
  }

  /// 吃到了子弹奖励
  void ateBullet() {
    _playerFire--;
  }

  /// 吃到了火箭奖励
  void ateRocket() {
    _rocketNum++;
  }
}
