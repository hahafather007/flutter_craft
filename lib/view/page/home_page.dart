import 'package:flutter/material.dart';
import 'package:flutter_craft/utils/system_util.dart';
import 'package:flutter_craft/view/page/game_page.dart';
import 'package:flutter_craft/view/background/home_ground.dart';
import 'package:flutter_craft/view/base_state.dart';
import 'package:flutter_craft/view/base_frame.dart';
import 'package:flutter_craft/utils/timer_util.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  @override
  State createState() => HomeState();
}

class HomeState extends BaseState<HomePage> with BaseFrame {
  final _pageController = PageController();

  HomeGround _ground;
  AudioPlayer _audioPlayer;
  int _secondPage = 0;
  bool _isPause = false;

  @override
  void init() {
    TimerUtil.init();

    _ground = HomeGround();

    // bgm
    final audio = AudioCache();
    audio.loop("home_bg.mp3").then((v) => _audioPlayer = v);
    bindSub(
        TimerUtil.renderStream.where((_) => !_isPause).listen((_) => render()));
    bindSub(
        TimerUtil.updateStream.where((_) => !_isPause).listen((_) => update()));
  }

  @override
  void dispose() {
    TimerUtil.dispose();
    _audioPlayer?.release();
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            // 背景图
            _ground,

            // 页面管理
            PageView(
              controller: _pageController,
              children: <Widget>[
                // 按钮页面
                _buildBtns(),

                // 第二页面
                _getSecondPage(),
              ],
            ),
          ],
        ),
      ),
      onWillPop: () async => false,
    );
  }

  /// 获取第二页面
  /// [_secondPage] 0表示[_StorePage],1表示[_AboutPage]
  Widget _getSecondPage() {
    if (_secondPage == 0) {
      return _StorePage(
        onBack: () {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        },
      );
    } else {
      return _AboutPage(
        onBack: () {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        },
      );
    }
  }

  /// 界面上的按钮
  Widget _buildBtns() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 120),
      child: Column(
        children: <Widget>[
          // 开始游戏
          Expanded(
            child: Center(
              child: _buildInkBtn(
                text: "开始",
                onTap: () async {
                  _isPause = true;
                  _audioPlayer?.pause();
                  await push(context, page: GamePage());
                  _isPause = false;
                  _audioPlayer?.seek(const Duration());
                  _audioPlayer?.resume();
                },
              ),
            ),
          ),

          // 商店
          Expanded(
            child: Center(
              child: _buildInkBtn(
                text: "商店",
                onTap: () {
                  setState(() => _secondPage = 0);
                  _pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear);
                },
              ),
            ),
          ),

          // 关于
          Expanded(
            child: Center(
              child: _buildInkBtn(
                text: "关于",
                onTap: () {
                  setState(() => _secondPage = 1);
                  _pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear);
                },
              ),
            ),
          ),

          // 退出
          Expanded(
            child: Center(
              child: _buildInkBtn(
                text: "退出",
                onTap: () async {
                  await _audioPlayer?.release();
                  exitApp();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInkBtn({@required String text, VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            "images/btn.png",
            width: 100,
            height: 50,
            fit: BoxFit.fill,
          ),
          Text(
            "$text",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void render() {
    _ground.render();
  }

  @override
  void update() {
    _ground.update();
  }

  @override
  bool canRecycle() {
    return false;
  }

  @override
  void reset() {}
}

/// 商店页面
class _StorePage extends StatefulWidget {
  final VoidCallback onBack;

  _StorePage({@required this.onBack});

  @override
  State createState() => _StoreState();
}

class _StoreState extends BaseState<_StorePage> {
  @override
  void init() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 标题栏
        _buildTitle(),
      ],
    );
  }

  /// 标题栏
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text("商店"),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: widget.onBack,
        ),
      ),
    );
  }
}

/// 关于页面
class _AboutPage extends StatefulWidget {
  final VoidCallback onBack;

  _AboutPage({@required this.onBack});

  @override
  State createState() {
    return _AboutState();
  }
}

class _AboutState extends BaseState<_AboutPage> {
  @override
  void init() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 标题栏
        _buildTitle(),
      ],
    );
  }

  /// 标题栏
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text("关于"),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: widget.onBack,
        ),
      ),
    );
  }
}
