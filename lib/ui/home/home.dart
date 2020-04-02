import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/page/home/left_drawer_widget.dart';
import 'package:gwgo_helper/page/leitai_page.dart';
import 'package:gwgo_helper/ui/promise/promise.dart';
import 'package:gwgo_helper/utils/common_utils.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  BuildContext context;
  List<String> titleList = [
    '妖灵扫描',
    '选择扫描妖灵',
    '五星御灵团战',
    '彩笔擂台',
    '扫描单人擂台',
    // '服务购买',
  ];
  List<String> subtitleList = [
    '根据选择的妖灵进行扫描',
    '选择需要扫描的妖灵',
    '只打五星御灵团战！',
    '偷擂利器！战力从低到高排序',
    '寻仇利器！扫描选定区域，玩家呢称包含特定字符的擂台',
    // '过期了？购买指示器使用时长',
  ];

  TextEditingController nameController = new TextEditingController();
  TextEditingController powerController = new TextEditingController();
  TextEditingController tokenController = new TextEditingController();

  var _searchName = "";
  var _searchPower = "";

  var _token = '';
  var _openid = '';

  @override
  Widget build(BuildContext context) {
    this.context = context;

    /// 第一次启动，自动跳转到使用说明
    Config.init(context);

    // getDeviceId();

    return Scaffold(
      drawer: DrawerLayout(),
      appBar: AppBar(
        title: Text('却邪剑'),
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
          // Container(
          //   height: 50,
          //   alignment: Alignment.center,
          //   margin: EdgeInsets.only(right: 15),
          //   child: IconButton(
          //     icon: Icon(
          //       Icons.settings,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       showDialog(
          //         context: context,
          //         builder: (context) {
          //           return StatefulBuilder(
          //             builder: (context, state) {
          //               return AlertDialog(
          //                 title: Text('输入抓包信息'),
          //                 content: Container(
          //                   child: Column(
          //                     mainAxisSize: MainAxisSize.min,
          //                     children: <Widget>[
          //                       TextField(
          //                         controller: tokenController,
          //                         maxLines: 5,
          //                         decoration: InputDecoration(
          //                           hintText: '抓包信息',
          //                           border: OutlineInputBorder(),
          //                         ),
          //                         onChanged: (text) {
          //                           state(() {
          //                             _token = text;
          //                           });
          //                         },
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //                 actions: <Widget>[
          //                   FlatButton(
          //                     child: Text(
          //                       '取消',
          //                       style: TextStyle(color: Colors.red),
          //                     ),
          //                     onPressed: () {
          //                       Navigator.pop(context);
          //                     },
          //                   ),
          //                   FlatButton(
          //                     child: Text('更新'),
          //                     onPressed: (_token == '')
          //                         ? null
          //                         : () {
          //                             token = tokenController.text;
          //                             toast('更新成功');
          //                             Navigator.pop(context);
          //                           },
          //                   ),
          //                 ],
          //               );
          //             },
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          _onTap(index);
        },
        borderRadius: BorderRadius.all(Radius.circular(4)),
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
                return StatefulBuilder(
                  builder: (context, state) {
                    return AlertDialog(
                      title: Text('输入要搜索人的昵称和战力'),
                      content: Container(
                        height: 120,
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 150,
                              child: TextField(
                                controller: nameController,
                                decoration: InputDecoration(hintText: '昵称'),
                                onChanged: (String value) {
                                  state(() {
                                    _searchName = nameController.text;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 150,
                              child: TextField(
                                controller: powerController,
                                decoration: InputDecoration(
                                  hintText: '战力',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly
                                ],
                                onChanged: (String value) {
                                  state(() {
                                    _searchPower = powerController.text;
                                  });
                                },
                              ),
                            ),
                          ],
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
                          color: Colors.blueAccent,
                          child: Text(
                            '确认',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: (null == _searchName ||
                                      _searchName.isEmpty) &&
                                  (null == _searchPower || _searchPower.isEmpty)
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  print('点击了确认');
                                  _openSingleLeitaiPage(
                                      _searchName, _searchPower);
                                },
                        )
                      ],
                    );
                  },
                );
              });
        }
        break;
      case 5:
        Navigator.pushNamed(context, '/juanzhu');
        break;
    }
  }

  _openSingleLeitaiPage(String name, String power) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return LeitaiPage(
            LeitaiPage.LEITAI_INDEX,
            name: name,
            power: power,
          );
        },
      ),
    );
  }
}
