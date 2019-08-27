import 'package:flutter/material.dart';
import 'base_gift.dart';

class BulletGift extends BaseGiftView {
  final _state = _BulletGiftState();

  BulletGift({Key key, @required Offset position})
      : super(key: key, position: position);

  @override
  BaseGiftState<BaseGiftView> get state => _state;
}

class _BulletGiftState extends BaseGiftState<BulletGift> {
  @override
  void init() {
    super.init();

    giftW = 14;
    giftH = 20;
    position =
        Offset(widget.position.dx - giftW / 2, widget.position.dy - giftH / 2);
    giftView = Image.asset(
      "images/bullet_gift.png",
      width: giftW,
      height: giftH,
      fit: BoxFit.fill,
    );
  }
}
