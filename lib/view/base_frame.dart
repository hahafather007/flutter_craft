/// 游戏画面每一帧的基础类
abstract class BaseFrame {
  /// 进行渲染
  void render();

  /// 进行数据处理
  void update();

  /// 判断对象是否能被回收
  bool canRecycle();
}
