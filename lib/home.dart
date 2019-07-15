import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/utils/dialog_utils.dart';
import 'page/leitai_page.dart';
import 'promise.dart';
import 'dart:io';
import 'config.dart';
import 'utils/common_utils.dart';

class HomePage extends StatelessWidget {
  BuildContext context;
  List<String> titleList = [
    '妖灵扫描',
    '选择扫描妖灵',
    '五星御灵团战',
    '彩笔擂台',
    '扫描单人擂台',
    '服务购买',
  ];
  List<String> subtitleList = [
    '根据选择的妖灵进行扫描',
    '选择需要扫描的妖灵',
    '只打句芒！',
    '战力从低到高的擂台',
    '扫描单人擂台',
    '购买指示器使用时长',
  ];

  @override
  Widget build(BuildContext context) {
    this.context = context;
    /// 加载注册数据
    PromiseInstance(context);
    return Scaffold(
      drawer: DrawerLayout(),
      appBar: AppBar(
        title: Text('飞行指示器'),
        actions: <Widget>[
          Container(
            height: 50,
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 15),
            child: IconButton(
              icon: Icon(
                Icons.place,
                color: Colors.white,
              ),
              onPressed: () async {
                if (await PromiseInstance(context).isPromise(context)) {
                  openAir();
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: _buildBody(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: TimeWidget(),
          ),
        ],
      )),
    );
  }

  List<Widget> _buildBody() {
    int index = 0;
    return titleList.map<Widget>((item) {
      return _buildItem(index++);
    }).toList();
  }

  Widget _buildItem(int index) {
    return GestureDetector(
      onTap: () {
        _onTap(index);
      },
      child: Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              title: Text(
                titleList[index],
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(subtitleList[index],
                        softWrap: true, style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              trailing: Icon(Icons.keyboard_arrow_right,
                  color: Colors.blue, size: 30.0)),
        ),
      ),
    );
  }

  TextEditingController nameController = new TextEditingController();

  _onTap(int index) async {
    switch (index) {
      case 0:
        if (await PromiseInstance(context).isPromise(context)) {
          Navigator.pushNamed(context, '/yaoling');
        }

        break;
      case 1:
        if (await PromiseInstance(context).isPromise(context)) {
          Navigator.pushNamed(context, '/selectYaoling');
        }
        break;
      case 2: //扫描五星团战
        if (await PromiseInstance(context).isPromise(context)) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return LeitaiPage(LeitaiPage.GROUP_INDEX);
          }));
        }
        break;
      case 3: // 扫描擂台排名
        if (await PromiseInstance(context).isPromise(context)) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return LeitaiPage(LeitaiPage.LEITAI_INDEX);
          }));
        }
        break;
      case 4: // 扫描单人擂台
        if (await PromiseInstance(context).isPromise(context)) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('输入要搜索人的呢称'),
                  content: Container(
                    child: TextField(
                      controller: nameController,
                    ),
                  ),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text(
                        '取消',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        print('点击了取消');
                      },
                      color: Colors.grey,
                    ),
                    RaisedButton(
                      child: Text(
                        '确认',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        print('点击了确认');
                        _openSingleLeitaiPage(nameController.text);
                      },
                    )
                  ],
                );
              });
        }
        break;
      case 5:
        Navigator.pushNamed(context, '/juanzhu');
        break;
    }
  }

  _openSingleLeitaiPage(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return LeitaiPage(
            LeitaiPage.LEITAI_INDEX,
            name: name,
          );
        },
      ),
    );
  }
}

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
          height: 880,
          width: 230,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildFlyWidgets(),
              _buildMultiFlyWidgets(),
              _buildStartAirWidgets(),
              _buildYaolingRangeWidget(),
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
    return xiyouList.map((item) {
      return _buildLocationItem(item);
    }).toList();
  }

  Widget _buildLocationItem(String name) {
    return Container(
      height: 40,
      child: RadioListTile(
        value: name,
        groupValue: selectedDemon,
        onChanged: (value) {
          setState(() {
            selectedDemon = value;
          });
          saveLocationRange();
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
      if (time.contains('到期时间：')) {
        timer.cancel();
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
