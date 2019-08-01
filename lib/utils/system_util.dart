import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 屏幕信息
double _screenWidth = 0;
double _screenHeight = 0;
double _statusHeight = 0;
double _appBarHeight = 0;

/// 获取屏幕宽度
double getScreenWidth(BuildContext context) {
  if (_screenWidth == 0) {
    final width = MediaQuery.of(context).size.width;
    _screenWidth = width;
  }

  return _screenWidth;
}

/// 获取屏幕高度
double getScreenHeight(BuildContext context) {
  if (_screenHeight == 0) {
    final height = MediaQuery.of(context).size.height;
    _screenHeight = height;
  }

  return _screenHeight;
}

/// 获取系统状态栏高度
double getStatusHeight(BuildContext context) {
  if (_statusHeight == 0) {
    final height = MediaQuery.of(context).padding.top;
    _statusHeight = height;
  }

  return _statusHeight;
}

/// 判断是否是畸形屏
bool isScreenDeformity(BuildContext context) => getStatusHeight(context) > 26;

/// 获取标题栏高度
double getAppBarHeight() {
  if (_appBarHeight == 0) {
    _appBarHeight = AppBar().preferredSize.height;
  }

  return _appBarHeight;
}

/// 关闭窗口
void pop(BuildContext context, {int count = 1, dynamic extraData}) {
  if (count == 1) {
    Navigator.pop(context, extraData);

    return;
  }

  for (int i = 0; i < count; i++) {
    Navigator.pop(context);
  }
}

/// 开启一个窗口
/// [replace] 是否代替当前界面
Future push<T extends Widget>(BuildContext context,
    {@required T page, bool replace = false}) {
  final route = MaterialPageRoute(builder: (_) => page);

  Future future;

  if (replace) {
    future = Navigator.of(context).pushReplacement(route);
  } else {
    future = Navigator.of(context).push(route);
  }

  return future;
}

/// 退出应用
void exitApp() => SystemNavigator.pop();