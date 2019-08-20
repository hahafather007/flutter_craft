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
  void render() {
    _state.render();
  }
}

class _PlayerBulletState extends BaseState<PlayerBulletView> with BaseFrame {
  final _bulletStream = StreamController<List<BaseBulletView>>();
  final _bullets = List<BaseBulletView>();
  final _pool = Soundpool(maxStreams: 10);

  int _skipNum = 0;
  int _bulletIndex = 0;
  int _soundId;

  @override
  void init() {
    // 玩家子弹发射音效
    rootBundle.load("assets/player_bullet.wav").then((data) async {
      _soundId = await _pool.load(data);
      _pool.setVolume(soundId: _soundId, volume: 0.1);
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
    if (_skipNum >= Settings.playerFire) {
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
      if (_soundId != null) {
        _pool.play(_soundId);
      }
    }
  }

  @override
  void render() {
    streamAdd(_bulletStream, _bullets);
    _bullets.forEach((v) => v.render());
  }
}
