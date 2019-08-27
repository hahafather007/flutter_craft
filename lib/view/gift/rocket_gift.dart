import 'package:flutter/material.dart';
import 'base_gift.dart';

class RocketGift extends BaseGiftView {
  final _state = _RocketGiftState();

  RocketGift({Key key, @required Offset position})
      : super(key: key, position: position);

  @override
  BaseGiftState<BaseGiftView> get state => _state;
}

class _RocketGiftState extends BaseGiftState<RocketGift> {
  @override
  void init() {
    super.init();

    giftW = 20;
    giftH = 20;
    position =
        Offset(widget.position.dx - giftW / 2, widget.position.dy - giftH / 2);
    giftView = Image.asset(
      "images/rocket_gift.png",
      width: giftW,
      height: giftH,
      fit: BoxFit.fill,
    );
  }
}
