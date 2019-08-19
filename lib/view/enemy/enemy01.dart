import 'package:flutter/material.dart';
import 'base_enemy.dart';
import 'package:flutter_craft/utils/system_util.dart';

class Enemy01 extends BaseEnemyView {
  final _state = _Enemy01State();

  Enemy01({Key key}) : super(key: key);

  @override
  BaseCraftState<BaseEnemyView> get state => _state;

  @override
  bool get canAttack => _state.canAttack;

  @override
  int attack(int value) => _state.attack(value);
}

class _Enemy01State extends BaseCraftState<Enemy01> {
  final _enemyW = 30.0;
  final _enemyH = 21.0;

  Widget _enemyView;

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
          child: StreamBuilder(
            stream: boomStateStream.stream,
            initialData: 0,
            builder: (context, snapshot) {
              final state = snapshot.data;

              return !isBoom && hp > 0 ? _enemyView : boomViews[state];
            },
          ),
        );
      },
    );
  }

  @override
  void init() {
    super.init();

    hp = 3;
    position = Offset(
        random.nextInt((getScreenWidth(context) - _enemyW).toInt()).toDouble(),
        -_enemyH - random.nextInt(100));
    xMove = random.nextDouble() / (random.nextBool() ? -2 : 2);
    yMove = random.nextDouble() * 1.5;
    if (yMove <= 0.3) {
      yMove += 0.3;
    }
    boomViews = List.generate(4, (index) {
      return Image.asset(
        "images/boom_state${index + 1}.png",
        width: _enemyW,
        height: _enemyW,
        fit: BoxFit.fill,
      );
    });

    _enemyView = Image.asset(
      "images/enemy01.png",
      width: _enemyW,
      height: _enemyH,
      fit: BoxFit.fill,
    );
  }

  @override
  bool canRecycle() {
    if (position == null || isBoom) {
      return false;
    }

    return hp <= 0 ||
        position.dy >= getScreenHeight(context) ||
        position.dx < -_enemyW ||
        position.dx > getScreenWidth(context);
  }

  @override
  Rect getRect() {
    if (position == null) {
      return null;
    }

    return Rect.fromPoints(Offset(position.dx, position.dy + _enemyH / 8),
        Offset(position.dx + _enemyW, position.dy + _enemyH / 5 * 4));
  }

  @override
  Offset getFirePos() {
    if (position == null) {
      return null;
    }

    return Offset(position.dx + _enemyW / 2, position.dy + _enemyH);
  }

  @override
  int attack(int value) {
    hp -= value;

    if (hp <= 0) {
      isBoom = true;

      return 1;
    }

    return 0;
  }

  @override
  bool get canAttack => hp > 0;
}
