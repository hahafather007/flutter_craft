import 'dart:async';
import 'package:flutter_craft/common/streams.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_craft/common/settings.dart';

class TimerUtil {
  static final _frameBroadcast = StreamController();

  static StreamSubscription _sub;
  static Stream frameStream;

  static void init() {
    frameStream = _frameBroadcast.stream.asBroadcastStream();
    changeFrame();
  }

  static void changeFrame() async {
    final seconds = Settings.IS_FRAME60 ? 16 : 33;

    await _sub?.cancel();
    _sub = Observable.periodic(Duration(milliseconds: seconds))
        .doOnData((v) => streamAdd(_frameBroadcast, v))
        .listen(null);
  }

  static void dispose() {
    _sub.cancel();
    _frameBroadcast.close();
  }
}
