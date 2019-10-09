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

  var isSearching = false;

  var _searchLayoutWidth = 0.toDouble();
  var _searchLayoutHeight = 55.toDouble();
  var _searchLayoutBgColor = Colors.transparent;
  var _searchController = TextEditingController();
  var _searchText = '';

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
      backgroundColor: Color(0xf0ffffff),
      endDrawer: SelectYaolingDrawerWidget(
        groupValue,
        (level) {
          groupValue = level;
          setState(() {});
        },
      ),
      appBar: AppBar(
        title: Text(
          '选择扫描妖灵：${getLevel()}',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 6.0,
                      runSpacing: -6.0,
                      children: _getAllYaolingWidgets(groupValue),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 16,
              child: AnimatedContainer(
                width: _searchLayoutWidth,
                height: _searchLayoutHeight,
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _searchLayoutBgColor,
                  borderRadius: BorderRadius.circular(100.toDouble()),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: TextField(
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.blueAccent),
                          decoration: InputDecoration(
                            hintText: '妖灵名称',
                          ),
                          controller: _searchController,
                          onChanged: (content) {
                            setState(() {
                              _searchText = content;
                            });
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        toggle();
                      },
                      child: Container(
                        width: 55,
                        height: 55,
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  toggle() {
    setState(() {
      isSearching = !isSearching;
      _searchLayoutWidth =
          isSearching ? MediaQuery.of(context).size.width - 30 : 0;
      // _searchLayoutHeight = isSearching ? 55 : 0;
      _searchLayoutBgColor =
          isSearching ? Color(0xffffffff) : Colors.transparent;
    });
  }

  Widget _buildFloatingActionButton() {
    if (isSearching) {
      return null;
    }
    return FloatingActionButton(
      onPressed: () {
        toggle();
      },
      child: Icon(Icons.search),
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
        if (isSearching && yaoling.Name.contains(_searchText) || !isSearching) {
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
      }
    });
    return widgetList;
  }

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
      width: 110,
      child: Chip(
        elevation: _elevation,
        backgroundColor: _buildBgColor(id),
        avatar: CircleAvatar(
          backgroundColor: Colors.white,
          child: _buildHeader(imgUrl, name),
        ),
        label: Container(
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
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
}
