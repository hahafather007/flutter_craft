import 'package:flutter/material.dart';
import 'base_bullet.dart';
import 'dart:math';

class PlayerBullet03 extends BaseBulletView {
  final _state = _PlayerBullet03State();

  final Offset playerPos;

  /// -1表示往左的子弹
  /// 0表示中间
  /// 1表示往右
  final int bulletType;

  PlayerBullet03({Key key, @required this.playerPos, @required this.bulletType})
      : super(key: key);

  @override
  BaseBulletState<BaseBulletView> get state => _state;
}

class _PlayerBullet03State extends BaseBulletState<PlayerBullet03> {
  final _bulletW = 7.5;
  final _bulletH = 16.0;

  Widget _bulletView;

  @override
  void init() {
    position = Offset(widget.playerPos.dx - _bulletW / 2, widget.playerPos.dy);
    switch (widget.bulletType) {
      case -1:
        xMove = -1;
        yMove = -sqrt(24);
        break;
      case 0:
        xMove = 0;
        yMove = -5;
        break;
      case 1:
        xMove = 1;
        yMove = -sqrt(24);
        break;
    }
    bulletFire = 1;

    _bulletView = Transform.rotate(
      angle: -xMove / yMove,
      child: Image.asset(
        "images/player_bullet1.png",
        width: _bulletW,
        height: _bulletH,
        fit: BoxFit.fill,
      ),
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
