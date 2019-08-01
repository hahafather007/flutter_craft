/// 游戏画面每一帧的基础类
abstract class BaseFrame {
  /// 进行下一帧计算
  void nextFrame();

  /// 判断对象是否能被回收
  bool canRecycle();
}
