import 'package:flutter/material.dart';

class IndicatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('功能介绍'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Text.rich(
            TextSpan(
              children: <TextSpan>[
                // TextSpan(text: '功能介绍:\n\n', style: TextStyle(fontSize: 18)),
                TextSpan(
                    text: '飞行器 - 绝对稳定！\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(text: '经纬度飞行，关闭GPS，摇杆操作，简单好用！\n\n'),
                TextSpan(
                    text: '妖灵扫描 - 最效率捉妖！\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        '自定义需要扫描的妖灵，扫描范围可选择<我的周围>或其它固定城市，在启动飞行器的情况下，扫描到妖灵后，点击按钮，直接飞行到妖灵身边，立即开抓；\nPS：如果距离妖灵很远，默认执行多次飞行，可在侧滑设置中关闭。\n\n'),
                TextSpan(
                    text: '五星御灵团战 - 只打五星！\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(text: ' 扫描选定位置的五星御灵团战并显示倒计时，在启动飞行器的情况下，点击可直接飞过去\n\n'),
                TextSpan(
                    text: '彩笔擂台 - 寻找附近最菜的擂台！\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        '扫描选定位置的擂台，根据擂台第一名队伍的战力从低到高排列，把附近最菜的擂台展示在你面前，大大降低偷擂被反制的风险！\n\n'),
                TextSpan(
                    text: '扫描单人擂台 - 寻仇利器！\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        '扫描选定位置内，名字包含特定字符的所有擂台，寻仇打架，专属利器！\nPS：输入对方名字中包含的字符即可，不需要完全匹配。\n\n'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
