class Settings {
  /// 是否开启60帧模式
  static bool isFrame60;

  /// 玩家子弹发射间隔帧（越小火力越强，最小为1）
  static int playerFire;

  /// 玩家发射火箭弹的威力
  static int rocketAttack;

  /// 火箭弹备弹
  static int rocketNum;

  /// 玩家子弹的射击模式
  static PlayShootMood playShootMood;
}

enum PlayShootMood {
  /// 单倍火力
  SINGLE,

  /// 双倍
  DOUBLE,

  ///三倍
  TREBLE,
}
