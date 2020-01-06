import 'package:flutter/material.dart';
import 'package:gwgo_helper/manager/yaoling_info.dart';
import 'package:gwgo_helper/sprite_ids.dart';
import 'package:gwgo_helper/ui/scanning/scanning_yaoling/select_yaoling/select_yaoling_drawer.dart';

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

  /// 当前选中级别的妖灵列表
  List yaolingList1 = List();
  List yaolingList2 = List();
  List yaolingList3 = List();
  List yaolingList4 = List();
  List yaolingList5 = List();

  List<Widget> widgetList = List();

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
  void initState() {
    processData();
    super.initState();
  }

  Future processData() async {
    print('开始处理数据:' + DateTime.now().millisecondsSinceEpoch.toString());
    if (YaolingInfoManager.yaolingMap == null ||
        YaolingInfoManager.yaolingMap.isEmpty) {
      print('YaolingInfoManager.yaolingMap is empty');
    }
    YaolingInfoManager.yaolingMap.forEach((id, yaoling) {
      switch (yaoling.Level) {
        case 1:
          yaolingList1.add(yaoling);
          break;
        case 2:
          yaolingList2.add(yaoling);
          break;
        case 3:
          yaolingList3.add(yaoling);
          break;
        case 4:
          yaolingList4.add(yaoling);
          break;
        case 5:
          yaolingList5.add(yaoling);
          break;
        default:
          break;
      }
    });
    print('数据处理完成:' + DateTime.now().millisecondsSinceEpoch.toString());
    _buildChildrenWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xf0ffffff),
      endDrawer: SelectYaolingDrawerWidget(
        groupValue,
        (level) {
          groupValue = level;
          _buildChildrenWidgets();
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
                      children: widgetList,
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
                              _searchText = content;
                            _buildChildrenWidgets();
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
      isSearching = !isSearching;
      _searchLayoutWidth =
          isSearching ? MediaQuery.of(context).size.width - 30 : 0;
      _searchLayoutBgColor =
          isSearching ? Color(0xffffffff) : Colors.transparent;
    _buildChildrenWidgets();
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

  _buildChildrenWidgets() {
    buildChildrenWidgets(groupValue);
  }

  Future<List<Widget>> buildChildrenWidgets(String level) async {
    print('开始构建widget:' + DateTime.now().millisecondsSinceEpoch.toString());
    widgetList.clear();
    List yaolingList;
    switch (level) {
      case '1':
        yaolingList = yaolingList1;
        break;
      case '2':
        yaolingList = yaolingList2;
        break;
      case '3':
        yaolingList = yaolingList3;
        break;
      case '4':
        yaolingList = yaolingList4;
        break;
      case '5':
        yaolingList = yaolingList5;
        break;
      default:
        break;
    }
    yaolingList.forEach((yaoling) {
      if (isSearching && yaoling.Name.contains(_searchText) || !isSearching) {
        Widget _child =
            getYaolingChip(yaoling.Id, yaoling.Name, yaoling.SmallImgPath);
        Widget chip = GestureDetector(
          onTap: () {
            SpriteConfig.toggle(yaoling);
            _buildChildrenWidgets();
          },
          child: _child,
        );
        widgetList.add(chip);
        setState(() {});
      }
    });
    print('widget构建完成:' + DateTime.now().millisecondsSinceEpoch.toString());
    return widgetList;
  }

  /// 构建妖灵选择框Widget
  Widget getYaolingChip(int id, String name, String imgUrl) {
    var _width;
    var _elevation = 2.0;
    if (isSelected(id)) {
      _elevation = 10.0;
      _width = 110.0;
    } else {
      _elevation = 2.0;
      _width = 108.0;
    }
    return Container(
      alignment: Alignment.center,
      width: 110,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        // transform: Matrix4.diagonal3Values(_angle, _angle, _angle),
        alignment: Alignment.center,
        width: _width,
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
    return SpriteConfig.selectedMap.contains(id);
  }
}
