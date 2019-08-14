import 'package:flutter/material.dart';
import 'base_bullet.dart';
import 'player_bullet01.dart';
import 'package:flutter_craft/view/player/player_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PlayerBulletView extends StatefulWidget {
  final _state = _PlayerBulletState();

  final PlayerView player;

  PlayerBulletView({@required this.player});

  @override
  State createState() => _state;

  List<BaseBulletView> get bullets => _state._bullets;
}

class _PlayerBulletState extends BaseState<PlayerBulletView> {
  final _bulletStream = StreamController<List<BaseBulletView>>();
  final _bullets = List<BaseBulletView>();
  final _pool = Soundpool(maxStreams: 10);

  int _skipNum = 0;
  int _bulletIndex = 0;

  @override
  void init() {
    // 玩家子弹发射音效
    int soundId;
    rootBundle.load("assets/player_bullet.wav").then((data) async {
      soundId = await _pool.load(data);
      _pool.setVolume(soundId: soundId, volume: 0.1);
    });

    // 创建玩家的子弹
    bindSub(TimerUtil.updateStream.map((_) => _skipNum++).listen((_) async {
      _bullets.forEach((v) => v.update());

      // 清理可回收的子弹
      _bullets.removeWhere((v) => v.canRecycle());

      // 发射子弹
      if (_skipNum >= 8) {
        _skipNum = 0;
        final bullet = PlayerBullet01(
            key: Key("PlayerBullet01${_bulletIndex++}"),
            playerPos: widget.player.getFirePos());
        _bullets.add(bullet);
        if (soundId != null) {
          _pool.play(soundId);
        }
      }
    }));

    // 绘制每一帧
    bindSub(TimerUtil.renderStream.listen((_) {
      streamAdd(_bulletStream, _bullets);
      _bullets.forEach((v) => v.render());
    }));
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
}
