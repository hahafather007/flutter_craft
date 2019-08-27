import 'package:flutter/material.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'dart:math';

abstract class BaseGiftView extends StatefulWidget with BaseFrame {
  final BaseGiftState state = null;
  final Offset position;

  BaseGiftView({Key key, @required this.position}) : super(key: key);

  @override
  State<StatefulWidget> createState() => state;

  Rect getRect() {
    return state.getRect();
  }

  @override
  void reset() {
    state.reset();
  }

  @override
  void render() {
    state.render();
  }

  @override
  void update() {
    state.update();
  }

  @override
  bool canRecycle() {
    return state.canRecycle();
  }

  void useGift() => state.useGift();
}

abstract class BaseGiftState<T extends BaseGiftView> extends BaseState<T>
    with BaseFrame {
  final _posStream = StreamController<Offset>();
  final _random = Random();

  Widget giftView;
  bool _isOutTime = false;
  bool _giftUsed = false;
  double _xMove;
  double _yMove;
  double giftH;
  double giftW;
  Offset position;
  Timer _timer;

  @override
  void init() {
    _timer = Timer(const Duration(seconds: 20), () => _isOutTime = true);
    _xMove = _random.nextDouble() * 2;
    _yMove = sqrt(4 - _xMove * _xMove);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _posStream.stream,
      initialData: position,
      builder: (context, snapshot) {
        final Offset pos = snapshot.data;

        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: giftView,
        );
      },
    );
  }

  @override
  void dispose() {
    _posStream.close();
    _timer?.cancel();

    super.dispose();
  }

  /// 获取当前的矩形区域
  Rect getRect() {
    if (position == null) {
      return null;
    }

    return Rect.fromPoints(
        position, Offset(position.dx + giftW, position.dy + giftH));
  }

  @override
  void render() {
    if (position == null) return;

    streamAdd(_posStream, position);
  }

  @override
  void reset() {}

  @override
  void update() {
    if (_giftUsed ||
        position == null ||
        _xMove == null ||
        _yMove == null ||
        giftH == null ||
        giftW == null) {
      return;
    }
    position = Offset(position.dx + _xMove, position.dy + _yMove);
    if (_isOutTime) {
      if (position.dy > getScreenHeight(context) ||
          position.dy < -giftH ||
          position.dx > getScreenWidth(context) ||
          position.dx < -giftW) {
        useGift();
      }
    } else {
      if (position.dy > getScreenHeight(context) - giftH) {
        position = Offset(position.dx, getScreenHeight(context) - giftH);
        final change = _xMove;
        _xMove = _xMove > 0 ? _yMove.abs() : -_yMove.abs();
        _yMove = -change.abs();
      } else if (position.dy < 0) {
        position = Offset(position.dx, 0);
        final change = _xMove;
        _xMove = _xMove > 0 ? _yMove.abs() : -_yMove.abs();
        _yMove = change.abs();
      } else if (position.dx > getScreenWidth(context) - giftW) {
        position = Offset(getScreenWidth(context) - giftW, position.dy);
        final change = _yMove;
        _yMove = _yMove > 0 ? _xMove.abs() : -_xMove.abs();
        _xMove = -change.abs();
      } else if (position.dx < 0) {
        position = Offset(0, position.dy);
        final change = _yMove;
        _yMove = _yMove > 0 ? _xMove.abs() : -_xMove.abs();
        _xMove = change.abs();
      }
    }
  }

  @override
  bool canRecycle() {
    return _giftUsed;
  }

  /// 子弹击中后调用
  void useGift() {
    _giftUsed = true;
  }
}
