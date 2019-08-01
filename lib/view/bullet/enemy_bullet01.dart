import 'package:flutter/material.dart';
import 'base_bullet.dart';

class EnemyBullet01 extends BaseBulletView {
  @override
  BaseBulletState<BaseBulletView> get state => _EnemyButtleState();
}

class _EnemyButtleState extends BaseBulletState<EnemyBullet01> {
  @override
  void init() {}

  @override
  Widget build(BuildContext context) {}

  @override
  bool canRecycle() {}

  @override
  Rect getRect() {
    
  }
}
