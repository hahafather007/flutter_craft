import 'package:flutter/material.dart';
import 'bullet_gift.dart';
import 'rocket_gift.dart';
import 'base_gift.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'dart:math';

class GiftView extends StatefulWidget with BaseFrame {
  final _state = _GiftState();

  @override
  void render() {
    _state.render();
  }

  @override
  bool canRecycle() {
    return _state.canRecycle();
  }

  @override
  State createState() {
    return _state;
  }

  @override
  void reset() {
    _state.reset();
  }

  @override
  void update() {
    _state.update();
  }

  void createGift(Offset position, {bool force = false, GiftType type}) {
    _state.createGift(position, force: force, type: type);
  }
}

class _GiftState extends BaseState<GiftView> with BaseFrame {
  final _giftStream = StreamController<List<BaseGiftView>>();
  final _gifts = List<BaseGiftView>();
  final _random = Random();

  @override
  void init() {}

  @override
  void dispose() {
    _giftStream.close();
    _gifts.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _giftStream.stream,
      initialData: _gifts,
      builder: (context, snapshot) {
        final gifts = snapshot.data;

        return Stack(
          children: gifts,
        );
      },
    );
  }

  @override
  void render() {
    _gifts.forEach((v) => v.render());
    streamAdd(_giftStream, _gifts);
  }

  @override
  void reset() {
    _gifts.clear();
  }

  @override
  bool canRecycle() {
    return false;
  }

  /// 创建奖励品
  /// [force] 表示是否强制创建
  void createGift(Offset position, {bool force = false, GiftType type}) {
    final canCreate = force ? true : _random.nextInt(99) > 10;

    if (!canCreate) return;

    if (type == null) {
      type = GiftType.values[_random.nextInt(1)];
    }
    switch (type) {
      case GiftType.BULLET:
        _gifts.add(BulletGift(
          position: position,
        ));
        break;
      case GiftType.ROCKET:
        break;
    }
  }

  @override
  void update() {
    _gifts.forEach((v) => v.update());
    _gifts.removeWhere((v) => v.canRecycle());
  }
}

/// 奖励品类型
enum GiftType {
  BULLET,
  ROCKET,
}
