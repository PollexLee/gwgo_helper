import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('使用指南'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Text.rich(
            TextSpan(
              children: <TextSpan>[
                // TextSpan(text: '功能介绍:\n\n', style: TextStyle(fontSize: 18)),
                TextSpan(
                    text: '御剑飞行 - 绝对稳定！\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        '1，关闭GPS，关闭WIFI，开启移动数据；\n2，打开 开发者选项 -> 模拟位置应用 -> 选中 『却邪剑』；\n3，启动『却邪剑』，授予指示器申请的所有权限，进入『御剑飞行』页面，选择飞行位置，然后点击『御剑飞行开始』，会出现摇杆（授予悬浮窗权限），通知栏中的通知有显示/隐藏摇杆 按钮。\n\n'),
                TextSpan(
                    text: '妖灵探测 - 最效率捉妖！\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        '点击『释放剑气，开始探测』，会显示出探测到的妖灵，在『御剑飞行』状态，点击妖灵，会直接飞行到妖灵身边，立即开抓；\nPS：如果距离妖灵很远，默认执行多次飞行，可在侧滑设置中关闭。\n\n'),
                TextSpan(
                    text: '令牌购买 - 获取操控权利！\n',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextSpan(text: '通过购买令牌，即可操『控却邪』剑为您所用。'),
                // TextSpan(
                //     text: '彩笔擂台 - 寻找附近最菜的擂台！\n',
                //     style:
                //         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // TextSpan(
                //     text:
                //         '扫描选定位置的擂台，根据擂台第一名队伍的战力从低到高排列，把附近最菜的擂台展示在你面前，大大降低偷擂被反制的风险！\n\n'),
                // TextSpan(
                //     text: '扫描单人擂台 - 寻仇利器！\n',
                //     style:
                //         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // TextSpan(
                //     text:
                //         '扫描选定位置内，名字包含特定字符的所有擂台，寻仇打架，专属利器！\nPS：输入对方名字中包含的字符即可，不需要完全匹配。\n\n'),
                // TextSpan(
                //     text: '扫描范围设置\n',
                //     style:
                //         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // TextSpan(
                //     text:
                //         ' 点击首页左上角按钮，会出现配置菜单，没一项都有说明，如有不清楚的，找QQ群：162411670 咨询。\n\n'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
