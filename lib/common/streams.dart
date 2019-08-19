import 'dart:async';
import 'package:flutter/material.dart' show protected;
export 'dart:async';

abstract class StreamSubController {
  final _subList = List<StreamSubscription>();

  @protected
  void bindSub(StreamSubscription sub) {
    _subList.add(sub);
  }

  @protected
  void subDispose() {
    _subList.forEach((v) => v.cancel());
  }
}

void streamAdd<T>(StreamController<T> controller, T data) {
  if (controller.isClosed) return;

  controller.add(data);
}
