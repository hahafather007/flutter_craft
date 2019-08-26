import 'package:flutter/material.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/model/shared_depository.dart';
import 'package:flutter_craft/common/settings.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/view/page/home_page.dart';

class SplashPage extends StatefulWidget {
  @override
  State createState() {
    return SplashState();
  }
}

class SplashState extends BaseState<SplashPage> {
  @override
  void init() {
    SharedDepository().initShared().then((shared) {
      Settings.isFrame60 = shared.isFrame60;
      Settings.playerFire = shared.playerFire;
      Settings.playShootMood = shared.playShootMood;
      Settings.rocketAttack = shared.rocketAttack;
      Settings.rocketNum = shared.rocketNum;
      Settings.playerHp = shared.playerHp;

      push(context, page: HomePage(), replace: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
