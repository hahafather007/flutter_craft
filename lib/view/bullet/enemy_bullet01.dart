import 'package:flutter/material.dart';
import 'base_bullet.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'dart:math';
import 'package:flutter_craft/common/settings.dart';

class EnemyBullet01 extends BaseBulletView {
  final _state = _EnemyBullet01State();

  /// 敌机发射子弹时的坐标
  final Offset enemyPos;
  final Offset playerPos;

  EnemyBullet01({@required this.enemyPos, @required this.playerPos});

  @override
  BaseBulletState<BaseBulletView> get state => _state;
}

class _EnemyBullet01State extends BaseBulletState<EnemyBullet01> {
  final _bulletW = 6.0;
  final _bulletH = 6.0;
  final _bulletSpeed = 3.0;

  @override
  void init() {
    position = widget.enemyPos;
    final xLength = widget.playerPos.dx - widget.enemyPos.dx;
    final yLength = widget.playerPos.dy - widget.enemyPos.dy;
    final scale = xLength / yLength;
    final singleLength = _bulletSpeed / sqrt(1 + scale * scale);
    yMove = singleLength;
    xMove = scale * singleLength;

    if (!Settings.IS_FRAME60) {
      yMove *= 2;
      xMove *= 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: Container(
        width: _bulletW,
        height: _bulletH,
        decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      ),
    );
  }

  @override
  bool canRecycle() {
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
    return Rect.fromPoints(
        position, Offset(position.dx + _bulletW, position.dy + _bulletH));
  }
}
