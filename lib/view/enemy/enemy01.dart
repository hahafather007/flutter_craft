import 'package:flutter/material.dart';
import 'base_enemy.dart';
import 'package:flutter_craft/utils/system_util.dart';

class Enemy01 extends BaseEnemyView {
  final _state = _Enemy01State();

  @override
  BaseCraftState<BaseEnemyView> get state => _state;

  @override
  bool get canAttack => _state.canAttack;

  @override
  Future<bool> attack(int value) => _state.attack(value);
}

class _Enemy01State extends BaseCraftState<Enemy01> {
  final _enemyW = 30.0;
  final _enemyH = 21.0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: posStream.stream,
      initialData: position,
      builder: (context, snapshot) {
        final Offset offset = snapshot.data;

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Image.asset(
            "images/enemy01.png",
            key: Key("Enemy01"),
            width: _enemyW,
            height: _enemyH,
            fit: BoxFit.fill,
          ),
        );
      },
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
  }

  @override
  bool canRecycle() {
    return hp <= 0 ||
        position.dy >= getScreenHeight(context) ||
        position.dx < -_enemyW ||
        position.dx > getScreenWidth(context);
  }

  @override
  Rect getRect() {
    return Rect.fromPoints(
        position, Offset(position.dx + _enemyW, position.dy + _enemyH));
  }

  @override
  Offset getFirePos() {
    return Offset(position.dx + _enemyW / 2, position.dy + _enemyH);
  }

  @override
  Future<bool> attack(int value) async {
    hp -= value;

    return hp <= 0;
  }

  @override
  bool get canAttack => true;
}
