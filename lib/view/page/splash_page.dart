import 'package:flutter/material.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/view/page/home_page.dart';
import 'package:flutter_craft/model/shared_depository.dart';
import 'package:flutter_craft/common/settings.dart';
import 'package:rxdart/rxdart.dart';

class SplashPage extends StatefulWidget {
  @override
  State createState() {
    return SplashState();
  }
}

class SplashState extends BaseState<SplashPage> {
  @override
  void init() {
    bindSub(Observable.zip2(
            Stream.fromFuture(SharedDepository().initShared()),
            Stream.fromFuture(Future.delayed(const Duration(seconds: 0))),
            (a, b) => a)
        .map((shared) => Settings.init(shared))
        .listen((_) => push(context, page: HomePage(), replace: true)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
