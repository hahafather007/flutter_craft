import 'package:flutter/material.dart';
import 'base_bullet.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'dart:math';

class EnemyBullet02 extends BaseBulletView {
  final _state = _EnemyBullet02State();

  /// 敌机发射子弹时的坐标
  final Offset enemyPos;
  final Offset playerPos;

  EnemyBullet02({Key key, @required this.enemyPos, @required this.playerPos})
      : super(key: key);

  @override
  BaseBulletState<BaseBulletView> get state => _state;
}

class _EnemyBullet02State extends BaseBulletState<EnemyBullet02> {
  final _bulletW = 6.0;
  final _bulletH = 6.0;
  final _bulletSpeed = 4.0;

  @override
  void init() {
    bulletFire = 1;
    position = Offset(widget.enemyPos.dx - _bulletW / 2, widget.enemyPos.dy);
    final xLength = widget.playerPos.dx - widget.enemyPos.dx;
    final yLength = widget.playerPos.dy - widget.enemyPos.dy;
    final scale = xLength / yLength;
    final singleLength = _bulletSpeed / sqrt(1 + scale * scale);
    yMove = yLength > 0 ? singleLength : -singleLength;
    xMove = scale * singleLength;
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
          child: Container(
            width: _bulletW,
            height: _bulletH,
            decoration: BoxDecoration(
                color: Colors.cyan, shape: BoxShape.circle),
          ),
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

    return position.dy < -_bulletH ||
        position.dy > getScreenHeight(context) ||
        position.dx < -_bulletW ||
        position.dx > getScreenWidth(context);
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
