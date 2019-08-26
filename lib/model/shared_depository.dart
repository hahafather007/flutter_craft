import 'package:flutter/material.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_craft/common/settings.dart' show PlayShootMood;

/// SharedPreference的管理仓库
class SharedDepository {
  /// 使用单利模式管理
  static final SharedDepository _depository = SharedDepository._internal();

  SharedPreferences _prefs;

  factory SharedDepository() => _depository;

  SharedDepository._internal() {
    debugPrint("SharedDepository初始化完成！");
  }

  Future<SharedDepository> initShared() async {
    _prefs = await SharedPreferences.getInstance();

    return this;
  }

  /// 是否开启60帧模式
  bool get isFrame60 => _getBool("isFrame60");

  Future<bool> setIsFrame60(bool value) => _prefs.setBool("isFrame60", value);

  /// 玩家子弹发射间隔帧（越小火力越强，20~1）
  int get playerFire => _getInt("playerFire", defaultValue: 20);

  Future<bool> setPlayerFire(int value) => _prefs.setInt("playerFire", value);

  /// 玩家发射火箭弹的威力
  int get rocketAttack => _getInt("rocketAttack", defaultValue: 10);

  Future<bool> setRocketAttack(int value) =>
      _prefs.setInt("rocketAttack", value);

  /// 火箭弹备弹
  int get rocketNum => _getInt("rocketNum", defaultValue: 10);

  Future<bool> setRocketNum(int value) => _prefs.setInt("rocketNum", value);

  /// 玩家子弹的射击模式
  PlayShootMood get playShootMood {
    final value = _getString("playShootMood",
        defaultValue: PlayShootMood.TREBLE.toString());
    for (final mood in PlayShootMood.values) {
      if (value == mood.toString()) {
        return mood;
      }
    }

    return PlayShootMood.SINGLE;
  }

  Future<bool> setPlayShootMood(PlayShootMood value) =>
      _prefs.setString("playShootMood", value.toString());

  /// =============================================
  ///                     分割线
  /// =============================================
  /// 用带有默认值的形式获取prefs的数据
  String _getString(String key, {String defaultValue}) {
    final value = _prefs.getString(key);

    if (value == null) {
      return defaultValue;
    }

    return value;
  }

  bool _getBool(String key, {bool defaultValue = false}) {
    final value = _prefs.getBool(key);

    if (value == null) {
      return defaultValue;
    }

    return value;
  }

  int _getInt(String key, {int defaultValue}) {
    final value = _prefs.getInt(key);

    if (value == null) {
      return defaultValue;
    }

    return value;
  }
}
