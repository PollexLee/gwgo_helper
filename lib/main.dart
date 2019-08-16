import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gwgo_helper/manager/yaoling_manager.dart';
import 'package:gwgo_helper/page/help.dart';
import 'package:gwgo_helper/page/indicator.dart';
import 'package:gwgo_helper/page/juanzhu.dart';
import 'package:gwgo_helper/page/plain_setting_page.dart';
import 'package:gwgo_helper/page/select_yaoling_page.dart';
import 'package:gwgo_helper/widget/yaoling_widget.dart';
import 'home.dart';
import 'manager/yaoling_info.dart';
import 'yaoling.dart';
import 'sprite_ids.dart';
import 'utils/common_utils.dart' as utils;
import 'config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 初始化妖灵数据
    YaolingInfoManager().init();
    // 初始化妖灵配置
    SpriteConfig.init();
    
    try {
      Config.init(context);
    } catch (exception) {
      print(exception);
    }

    return MaterialApp(
      title: '飞行指示器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/yaoling': (context) => MyHomePage(title: '稀有'),
        '/juanzhu': (context) => JuanzhuPage(),
        '/selectYaoling': (context) => SelectYaolingPage(),
        '/plainSetting': (context) => PlainSettingPage(),
        '/indicator': (context) => IndicatorPage(),
        '/help': (context) => HelpPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  int time = 0;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  var buttonText = '扫描中';
  List<Yaoling> yaolingData = List();
  YaolingManager manager;
  String process = '';
  Timer timer;
  bool isCreate = false;

  @override
  void initState() {
    manager = YaolingManager();
    manager.init((int status) {
      if (status == 0 && !isCreate) {
        isCreate = true;
        _refreshYaoling();
      } else if (status == 1) {
        manager.close();
        setState(() {
          buttonText = '扫描结束';
        });
      }
    });

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      widget.time++;
      setState(() {});
    });
    super.initState();
  }

  void _refreshYaoling() {
    bool isNotice = false;
    manager.refreshYaoling((List<Yaoling> data, String process) {
      this.buttonText = process;
      if (process == "扫描完成") {
        timer.cancel();
      }
      if (data == null) {
      } else if (data.isNotEmpty) {
        if (yaolingData.length > 200) {
          if (!isNotice) {
            isNotice = true;
            key.currentState.showSnackBar(SnackBar(
              content: Text('妖灵数量已大于200，不再添加'),
            ));
          }
          return;
        }
        Color color = getNextColor();
        data.forEach((item) {
          if (item.isClick == false && clickYaolingData.contains(item)) {
            item.isClick = true;
          }
          item.color = color;
        });
        yaolingData.addAll(data);
      }
      setState(() {});
    });
  }

  int colorIndex = 0;
  List<Color> colorList = [Colors.white];

  Color getNextColor() {
    if (colorIndex >= colorList.length) {
      colorIndex = 0;
    }
    return colorList[colorIndex++];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(widget.title +
            ' - ' +
            selectedLocation +
            ' - ${yaolingData.length}个'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildYaoling(yaolingData),
            Container(
              alignment: Alignment.center,
              child: Text(buttonText + '  耗时：${widget.time.toString()}秒'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建妖灵列表
  Widget _buildYaoling(List<Yaoling> data) {
    List<Widget> widgetList = List();
    // 遍历妖灵数据
    if (null != data && data.isNotEmpty) {
      data.forEach((yaoling) {
        widgetList.add(YaolingWidget(
          yaoling,
          onTap: () {
            clickYaolingData.add(yaoling);
            utils.teleport(yaoling.latitude / 1e6, yaoling.longtitude / 1e6);
          },
        ));
      });
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.start,
      children: widgetList,
    );
  }

  @override
  void dispose() {
    manager.close();
    // manager = null;
    timer.cancel();
    timer = null;
    super.dispose();
  }
}
