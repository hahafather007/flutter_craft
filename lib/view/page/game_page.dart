import 'package:flutter/material.dart';
import 'package:flutter_craft/view/enemy/enemy_view.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/player/player_view.dart';

class GamePage extends StatefulWidget {
  @override
  State createState() => GameState();
}

class GameState extends BaseState<GamePage> {
  @override
  void init() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 敌机图层
          EnemyView(),

          // 玩家图层
          PlayerView(),
        ],
      ),
    );
  }
}
