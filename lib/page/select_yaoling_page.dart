import 'package:flutter/material.dart';
import 'package:gwgo_helper/manager/yaoling_info.dart';
import 'package:gwgo_helper/page/select_yaoling_drawer.dart';
import '../sprite_ids.dart';

class SelectYaolingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelectYaolingState();
  }
}

class SelectYaolingState extends State<SelectYaolingPage> {
  var groupValue = '1';

  String getLevel() {
    var levelStr = '';
    switch (groupValue) {
      case '1':
        levelStr = '一阶';
        break;
      case '2':
        levelStr = '二阶';
        break;
      case '3':
        levelStr = '三阶';
        break;
      case '4':
        levelStr = '四阶';
        break;
      case '5':
        levelStr = '五阶';
        break;
    }
    return levelStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: SelectYaolingDrawerWidget(
        groupValue,
        (level) {
          groupValue = level;
          setState(() {});
        },
      ),
      appBar: AppBar(
        title: Text('选择扫描妖灵：${getLevel()}', style: TextStyle(fontSize: 16),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // _buildTitle('稀有妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getAllYaolingWidgets(groupValue),
            ),
            // _buildTitle('全员恶人'),
            // Wrap(
            //   spacing: 8.0,
            //   runSpacing: 1.0,
            //   children: _getYaolingWidgets(SpriteConfig.erenMap),
            // ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getAllYaolingWidgets(String level) {
    List<Widget> widgetList = List();
    if (YaolingInfoManager.yaolingMap == null ||
        YaolingInfoManager.yaolingMap.isEmpty) {
      return widgetList;
    }
    if (YaolingInfoManager.yaolingMap.isEmpty) {
      print('YaolingInfoManager.yaolingMap is empty');
      return widgetList;
    }
    YaolingInfoManager.yaolingMap.forEach((id, yaoling) {
      if (yaoling.Level.toString() == level) {
        Widget _child =
            getYaolingChip(yaoling.Id, yaoling.Name, yaoling.SmallImgPath);
        Widget chip = GestureDetector(
          onTap: () {
            SpriteConfig.toggle(yaoling);
            setState(() {});
          },
          child: _child,
        );
        widgetList.add(chip);
      }
    });
    return widgetList;
  }

  // List<Widget> _getYaolingWidgets(Map<int, String> spriteMap) {
  //   List<Widget> widgetList = List();
  //   if (YaolingInfoManager.yaolingMap == null ||
  //       YaolingInfoManager.yaolingMap.isEmpty) {
  //     return widgetList;
  //   }

  //   if (spriteMap.isEmpty) {
  //     print('spriteMap is empty');
  //   }

  //   if (YaolingInfoManager.yaolingMap.isEmpty) {
  //     print('YaolingInfoManager.yaolingMap is empty');
  //   }

  //   spriteMap.forEach((id, item) {
  //     if (YaolingInfoManager.yaolingMap.containsKey(id)) {
  //       Yaoling yaoling = YaolingInfoManager.yaolingMap[id];
  //       Widget _child =
  //           getYaolingChip(yaoling.Id, yaoling.Name, yaoling.SmallImgPath);
  //       Widget chip = GestureDetector(
  //         onTap: () {
  //           SpriteConfig.toggle(yaoling);
  //           setState(() {});
  //         },
  //         child: _child,
  //       );
  //       widgetList.add(chip);
  //     } else {
  //       Yaoling yaoling = Yaoling();
  //       yaoling.Id = id;
  //       yaoling.Name = item;
  //       Widget _child =
  //           getYaolingChip(yaoling.Id, yaoling.Name, yaoling.SmallImgPath);
  //       Widget chip = GestureDetector(
  //         onTap: () {
  //           SpriteConfig.toggle(yaoling);
  //           setState(() {});
  //         },
  //         child: _child,
  //       );
  //       widgetList.add(chip);
  //     }
  //   });
  //   return widgetList;
  // }

  /// 构建妖灵选择框Widget
  Widget getYaolingChip(int id, String name, String imgUrl) {
    var _angle;
    var _elevation = 2.0;
    if (isSelected(id)) {
      _elevation = 10.0;
      _angle = 1.03;
    } else {
      _elevation = 2.0;
      _angle = 1.0;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      transform: Matrix4.diagonal3Values(_angle, _angle, _angle),
      child: Chip(
        elevation: _elevation,
        backgroundColor: _buildBgColor(id),
        avatar: CircleAvatar(
          backgroundColor: Colors.white,
          child: _buildHeader(imgUrl, name),
        ),
        label: Text(
          name,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildHeader(String imgUrl, String name) {
    if (null != imgUrl) {
      return Image.network(
        imgUrl,
        fit: BoxFit.contain,
      );
    } else {
      return Text(
        name.substring(0, 1),
        textAlign: TextAlign.center,
      );
    }
  }

  Color _buildBgColor(int id) {
    if (isSelected(id)) {
      return Colors.blue;
    } else {
      return Colors.white;
    }
  }

  bool isSelected(int id) {
    return SpriteConfig.selectedMap.containsKey(id);
  }

  Widget _buildTitle(String title) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
