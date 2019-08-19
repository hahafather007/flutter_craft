import 'package:flutter/material.dart';
import 'package:flutter_craft/common/streams.dart';
export 'package:flutter_craft/common/streams.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T>
    with StreamSubController {
  bool _hasInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInit) {
      _hasInit = true;
      init();
    }
  }

  @override
  void dispose() {
    subDispose();

    super.dispose();
  }

  void init();
}
