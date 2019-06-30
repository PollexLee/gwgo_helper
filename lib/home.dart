import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'page/leitai_page.dart';
import 'promise.dart' as promise;
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

    promise.isPromise();

    return Scaffold(
      drawer: DrawerLayout(),
      appBar: AppBar(title: Text('飞行指示器')),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: titleList.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildItem(index);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: _buildTime(),
          ),
        ],
      )),
    );
  }

  Widget _buildTime(){
    // if(promise.get){

    // }

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

  double lat = 40.066;
  double lon = 116.2283;
  _onTap(int index) {
    switch (index) {
      case 0:
        promise.isPromise();
        Navigator.pushNamed(context, '/yaoling');
        break;
      case 1:
        promise.isPromise();
        Navigator.pushNamed(context, '/selectYaoling');
        break;
      case 2: //扫描五星团战
        promise.isPromise();
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return LeitaiPage(LeitaiPage.GROUP_INDEX);
        }));
        break;
      case 3: // 扫描擂台排名
        promise.isPromise();
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return LeitaiPage(LeitaiPage.LEITAI_INDEX);
        }));
        break;
      case 4: // 扫描单人擂台
        promise.isPromise();
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildConfigWidgets(),
            Expanded(
              child: _buildLocationDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigWidgets() {
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
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDrawer() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: xiyouList.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildLocationItem(index);
        },
      ),
    );
  }

  Widget _buildLocationItem(int index) {
    var name = xiyouList[index];
    return Container(
      height: 40,
      child: RadioListTile(
        value: name,
        groupValue: selectedDemon,
        onChanged: (value) {
          setState(() {
            selectedDemon = value;
          });
        },
        title: Text(name),
      ),
    );
  }
}
