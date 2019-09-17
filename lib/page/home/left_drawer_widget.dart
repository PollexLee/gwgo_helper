import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:gwgo_helper/utils/dialog_utils.dart';

import '../../config.dart';
import '../../promise.dart';

class DrawerLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DrawerState();
  }
}

class DrawerState extends State<DrawerLayout> {
  TextStyle titleStyle =
      TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        primary: true,
        child: Container(
          color: Colors.white,
          height: 1000,
          width: 230,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildFlyWidgets(),
              _buildMultiFlyWidgets(),
              _buildStartAirWidgets(),
              _buildYaolingRangeWidget(),
              _buildPlainsWidget(),
              Expanded(
                child: _buildLocationDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlyWidgets() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 22),
        child: Row(
          children: <Widget>[
            Text(
              "开启飞行",
              style: TextStyle(color: Colors.black),
            ),
            Switch(
              onChanged: (bool value) {
                setOpenFly(value);
                setState(() {});
                print('现在是$isOpenFly');
              },
              value: isOpenFly,
            ),
            IconButton(
              icon: Icon(
                Icons.assignment,
                color: Colors.blue,
              ),
              onPressed: () {
                DialogUtils.showNoticeDialog(
                    context, '开启 - 调用飞行器飞到妖灵位置；\n\n关闭 - 复制经纬度到粘贴板。');
              },
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiFlyWidgets() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 22),
        child: Row(
          children: <Widget>[
            Text(
              "多次飞行",
              style: TextStyle(color: Colors.black),
            ),
            Switch(
              onChanged: (bool value) {
                setOpenMultiFly(value);
                setState(() {});
                print('现在是$isOpenMultiFly');
              },
              value: isOpenMultiFly,
            ),
            IconButton(
              icon: Icon(
                Icons.assignment,
                color: Colors.blue,
              ),
              onPressed: () {
                DialogUtils.showNoticeDialog(context,
                    '开启飞行时有效！！！\n\n开启 - 使用安全距离多次飞行到目地低\n\n关闭 - 一次性直接飞行到目地低');
              },
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildStartAirWidgets() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 22),
        child: Row(
          children: <Widget>[
            Text(
              "自动启动游戏",
              style: TextStyle(color: Colors.black),
            ),
            Switch(
              onChanged: (bool value) {
                setStartAir(value);
                setState(() {});
                print('现在是$isStartAir');
              },
              value: isStartAir,
            ),
            IconButton(
              icon: Icon(
                Icons.assignment,
                color: Colors.blue,
              ),
              onPressed: () {
                DialogUtils.showNoticeDialog(context,
                    '开启飞行时有效！！！\n\n开启 - 点击妖灵头像，自动切换到游戏\n\n关闭 - 点击妖灵头像，不自动切换到游戏');
              },
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildYaolingRangeWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '选择妖灵范围',
                  style: titleStyle,
                ),
                IconButton(
                  icon: Icon(
                    Icons.assignment,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    DialogUtils.showNoticeDialog(context,
                        '扫描位置是 - 我的周围 时有效！！！\n\n 极小 - 适用于活动妖灵\n小 - 适用于稀有妖灵\n中、大 - 适用于附近妖灵比较少的场景（农村），有软封风险！');
                  },
                ),
                Expanded(child: Container()),
              ],
            ),
            Container(
              alignment: Alignment.topLeft,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildRangeWidgetList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRangeWidgetList() {
    return rangeList.map((item) {
      return Container(
        height: 40,
        child: RadioListTile(
          value: item,
          groupValue: rangeSelect,
          onChanged: (value) {
            rangeSelect = value;
            saveYaolingRange();
            setState(() {});
          },
          title: Text(item),
        ),
      );
    }).toList();
  }

  Widget _buildLocationDrawer() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 22, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '选择扫描位置',
                  style: titleStyle,
                ),
                IconButton(
                  icon: Icon(
                    Icons.assignment,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    DialogUtils.showNoticeDialog(context,
                        '我的周围 - 扫描虚拟位置或真实位置附近区域，可配合妖灵范围使用\n其它城市 - 已设置好的其它城市市区区间\n\n提示：远距离飞行有风险，使用须谨慎！');
                  },
                ),
                Expanded(child: Container()),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: _buildLocationListWidget(),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLocationListWidget() {
    return locationList.map((item) {
      return _buildLocationItem(item);
    }).toList();
  }

  Widget _buildLocationItem(String name) {
    return Container(
      height: 40,
      child: RadioListTile(
        value: name,
        groupValue: selectedLocation,
        onChanged: (value) {
          setState(() {
            selectedLocation = value;
          });
          saveLocationRange();
          if (value == '自定义区域') {
            setSelectArea((String data) {
              if (null == data || data.isEmpty) {
                toast('没有选择有效的自定义区域');
                return;
              }
              saveSelectArea(data);
              parseArea(data);
            });
          }
        },
        title: Text(name),
      ),
    );
  }

  Widget _buildPlainsWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 22, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '选择飞行器',
                  style: titleStyle,
                ),
                IconButton(
                  icon: Icon(
                    Icons.assignment,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    DialogUtils.showNoticeDialog(context, '选择正在使用的飞行器');
                  },
                ),
                Expanded(child: Container()),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: _buildPlainList(),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlainList() {
    return plainList.map((item) {
      return _buildPlainItem(item);
    }).toList();
  }

  Widget _buildPlainItem(String name) {
    return Container(
      height: 40,
      child: RadioListTile(
        value: name,
        groupValue: selectPlain,
        onChanged: (value) {
          setState(() {
            selectPlain = value;
          });
          saveSelectPlain();
        },
        title: Text(name),
      ),
    );
  }
}

class TimeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TimeState();
  }
}

class TimeState extends State<TimeWidget> {
  Timer timer;
  String time;
  @override
  void initState() {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (time.contains('到期时间：') || time.contains('已过期')) {
        timer.cancel();
        if (time.contains('已过期')) {
          toast('设备注册已过期，请及时续费');
          Navigator.pushNamed(context, '/juanzhu');
        }
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTime();
  }

  Widget _buildTime() {
    time = PromiseInstance(context).getLastTime();
    return Text(time);
  }
}
