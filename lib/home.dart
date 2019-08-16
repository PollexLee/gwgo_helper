
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/page/home/left_drawer_widget.dart';
import 'page/leitai_page.dart';
import 'promise.dart';
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
    '只打五星御灵团战！',
    '偷擂利器！战力从低到高排序',
    '寻仇利器！扫描选定区域，玩家呢称包含特定字符的擂台',
    '过期了？购买指示器使用时长',
  ];

  @override
  Widget build(BuildContext context) {
    this.context = context;

    /// 第一次启动，自动跳转到使用说明
    Config.init(context);

    return Scaffold(
      drawer: DrawerLayout(),
      appBar: AppBar(
        title: Text('飞行指示器'),
        actions: <Widget>[
          Container(
            height: 50,
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(
                Icons.help,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/help');
              },
            ),
          ),
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
                  Navigator.pushNamed(context, '/plainSetting');
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
