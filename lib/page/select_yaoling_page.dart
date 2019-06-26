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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildTitle('稀有妖灵'),
            Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: _getYaolingWidgets(SpriteConfig.spriteMap),
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
            style: TextStyle(color: Colors.black),
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
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
