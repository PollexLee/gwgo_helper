import 'package:flutter/material.dart';
import 'package:gwgo_helper/manager/yaoling_info.dart';
import 'package:gwgo_helper/model/yaoling.dart';
import '../sprite_ids.dart';

class SelectYaolingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelectYaolingState();
  }
}

class SelectYaolingState extends State<SelectYaolingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择扫描妖灵'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildTitle('稀有妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getYaolingWidgets(SpriteConfig.spriteMap),
            ),
            _buildTitle('星宿妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getYaolingWidgets(SpriteConfig.starMap),
            ),
            _buildTitle('元素妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getYaolingWidgets(SpriteConfig.elementMap),
            ),
            _buildTitle('人生赢家妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getYaolingWidgets(SpriteConfig.winnerMap),
            ),
            _buildTitle('鲲妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getYaolingWidgets(SpriteConfig.shipMap),
            ),
            _buildTitle('地域妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getYaolingWidgets(SpriteConfig.locationMap),
            ),
            _buildTitle('巢穴妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getYaolingWidgets(SpriteConfig.nestMap),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getYaolingWidgets(Map<int, String> spriteMap) {
    List<Widget> widgetList = List();
    if (YaolingInfoManager.yaolingMap == null ||
        YaolingInfoManager.yaolingMap.isEmpty) {
      return widgetList;
    }

    if (spriteMap.isEmpty) {
      print('spriteMap is empty');
    }

    if (YaolingInfoManager.yaolingMap.isEmpty) {
      print('YaolingInfoManager.yaolingMap is empty');
    }

    spriteMap.forEach((id, item) {
      if (YaolingInfoManager.yaolingMap.containsKey(id)) {
        Yaoling yaoling = YaolingInfoManager.yaolingMap[id];
        ActionChip chip = ActionChip(
          elevation: 3.0,
          backgroundColor: _buildBgColor(yaoling),
          avatar: CircleAvatar(
            backgroundColor: Colors.white,
            child: Image.network(
              yaoling.SmallImgPath,
              fit: BoxFit.contain,
            ),
          ),
          label: Text(
            yaoling.Name,
            style: TextStyle(color: Colors.black, fontSize: 13),
          ),
          onPressed: () {
            SpriteConfig.toggle(yaoling);
            setState(() {});
          },
        );
        widgetList.add(chip);
      }
    });
    return widgetList;
  }

  Color _buildBgColor(Yaoling yaoling) {
    if (SpriteConfig.selectedMap.containsKey(yaoling.Id)) {
      return Colors.blue;
    } else {
      return Colors.white;
    }
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
