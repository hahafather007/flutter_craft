import 'package:flutter_craft/common/streams.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_craft/common/settings.dart';

class TimerUtil {
  /// 通知进行渲染的广播
  static final _renderBroadcast = StreamController();

  /// 通知进行逻辑处理的广播
  static final _updateBroadcast = StreamController();

  static bool _isPause = false;
  static StreamSubscription _sub1;
  static StreamSubscription _sub2;
  static Stream renderStream;
  static Stream updateStream;

  static bool get isPause => _isPause;

  static void init() {
    renderStream = _renderBroadcast.stream.asBroadcastStream();
    updateStream = _updateBroadcast.stream.asBroadcastStream();

    _sub2 = Observable.periodic(const Duration(milliseconds: 16))
        .where((_) => !_isPause)
        .doOnData((v) => streamAdd(_updateBroadcast, v))
        .listen(null);
    changeFrame();
  }

  static void changeFrame() async {
    final seconds = Settings.isFrame60 ? 16 : 33;

    await _sub1?.cancel();
    _sub1 = Observable.periodic(Duration(milliseconds: seconds))
        .where((_) => !_isPause)
        .doOnData((v) => streamAdd(_renderBroadcast, v))
        .listen(null);
  }

  static void pause() {
    _isPause = true;
  }

  static void resume() {
    _isPause = false;
  }

  static void dispose() {
    _sub1.cancel();
    _sub2.cancel();
    _renderBroadcast.close();
    _updateBroadcast.close();
  }
}
