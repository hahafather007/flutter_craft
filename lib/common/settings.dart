class Settings {
  /// 是否开启60帧模式
  static bool isFrame60 = false;

  /// 玩家子弹的射击模式
  static PlayShootMood playShootMood = PlayShootMood.TREBLE;
}

enum PlayShootMood {
  /// 单倍火力
  SINGLE,

  /// 双倍
  DOUBLE,

  ///三倍
  TREBLE,
}
