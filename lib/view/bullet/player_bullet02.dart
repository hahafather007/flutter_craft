import 'package:flutter/material.dart';
import 'base_bullet.dart';

class PlayerBullet02 extends BaseBulletView {
  final _state = _PlayerBullet02State();

  final Offset playerPos;

  PlayerBullet02({Key key, @required this.playerPos}) : super(key: key);

  @override
  BaseBulletState<BaseBulletView> get state => _state;
}

class _PlayerBullet02State extends BaseBulletState<PlayerBullet02> {
  final _bulletW = 15.0;
  final _bulletH = 16.0;

  Widget _bulletView;

  @override
  void init() {
    position = Offset(widget.playerPos.dx - _bulletW / 2, widget.playerPos.dy);
    xMove = 0;
    yMove = -5;
    bulletFire = 2;

    _bulletView = Image.asset(
      "images/player_bullet2.png",
      width: _bulletW,
      height: _bulletH,
      fit: BoxFit.fill,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: posStream.stream,
      initialData: position,
      builder: (context, snapshot) {
        final Offset offset = snapshot.data;

        return Positioned(
          top: offset.dy,
          left: offset.dx,
          child: _bulletView,
        );
      },
    );
  }

  @override
  bool canRecycle() {
    if (bulletUsed) {
      return true;
    }

    if (position == null) {
      return false;
    }

    return position.dy < -_bulletH;
  }

  @override
  Rect getRect() {
    if (position == null) {
      return null;
    }

    return Rect.fromPoints(
        position, Offset(position.dx + _bulletW, position.dy + _bulletH));
  }
}
