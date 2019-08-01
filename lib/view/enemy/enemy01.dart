import 'package:flutter/material.dart';
import 'base_craft.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/common/settings.dart';

class Enemy01 extends BaseCraftView {
  final _mState = _Enemy01State();

  @override
  BaseCraftState<BaseCraftView> get state => _mState;
}

class _Enemy01State extends BaseCraftState<Enemy01> {
  final _enemyH = 10.0;
  final _enemyW = 10.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: _enemyW,
        height: _enemyH,
        color: Colors.black,
      ),
    );
  }

  @override
  void init() {
    hp = 3;
    position = Offset(
        random.nextInt((getScreenWidth(context) - _enemyW).toInt()).toDouble(),
        -_enemyH - random.nextInt(100));
    xMove = random.nextDouble() / (random.nextBool() ? -2 : 2);
    yMove = random.nextDouble() * 1.5;
    if (yMove <= 0.3) {
      yMove += 0.3;
    }

    if (!Settings.IS_FRAME60) {
      yMove *= 2;
      xMove *= 2;
    }
  }

  @override
  bool canRecycle() {
    return hp <= 0 ||
        position.dy >= getScreenHeight(context) ||
        position.dx < -_enemyW ||
        position.dx > getScreenWidth(context);
  }
}
