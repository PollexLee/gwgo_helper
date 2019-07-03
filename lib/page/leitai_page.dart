import 'package:flutter/material.dart';
import 'package:gwgo_helper/manager/leitai_manager.dart';
import 'package:gwgo_helper/model/leitai.dart';
import 'package:gwgo_helper/widget/group_widget.dart';
import 'package:gwgo_helper/widget/plarform_widget.dart';

import '../radar_socket.dart';
import '../widget/egg_widget.dart';
import '../utils/common_utils.dart' as utils;

class LeitaiPage extends StatefulWidget {
  // 首页条目索引
  int index = GROUP_INDEX;

  /// 团战
  static int GROUP_INDEX = 1;

  /// 擂台
  static int LEITAI_INDEX = 2;
  String name = '';

  String title = '擂台扫描';

  LeitaiPage(this.index, {this.name});

  @override
  State<StatefulWidget> createState() {
    // 修改标题
    if (name != null && name != '') {
      title = '$name - 开始扫描';
    }
    return LeitaiState();
  }
}

class LeitaiState extends State<LeitaiPage> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  List<Leitai> leitaiList = List();
  LeitaiManager manager;

  int _getLeitaiType(int index) {
    if (index == LeitaiPage.GROUP_INDEX) {
      return LEITAI_TYPE_GROUP;
    } else if (index == LeitaiPage.LEITAI_INDEX) {
      return LEITAI_TYPE_NORMAL;
    }
  }

  @override
  void initState() {
    manager = LeitaiManager();
    manager.init((int status) {
      print('初始化完成');
      if (status == 0) {
        _refreshLeitai();
      } else if (status == 1) {
        manager.close();
      }
    });
    super.initState();
  }

  void _refreshLeitai() {
    manager.refreshLeitai((List<Leitai> data, String process) {
      if (widget.name == null || widget.name == '') {
        widget.title = '$process';
      } else {
        widget.title = '${widget.name} - $process';
      }
      if (data.isNotEmpty) {
        data.forEach((leitai) {
          if (_getLeitaiType(widget.index) == LEITAI_TYPE_NORMAL &&
              leitai.isNormal()) {
            if (widget.name == null || widget.name == '') {
              leitaiList.add(leitai);
            } else {
              if (leitai.winner_name.contains(widget.name)) {
                leitaiList.add(leitai);
              }
            }
          } else if (_getLeitaiType(widget.index) == LEITAI_TYPE_GROUP &&
              leitai.isGroup()) {
            leitaiList.add(leitai);
          }
        });
        // 排序
        if (_getLeitaiType(widget.index) == LEITAI_TYPE_NORMAL) {
          leitaiList.sort((left, right) =>
              left.getYaolingPower().compareTo(left.getYaolingPower()));
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 14),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (null == leitaiList || leitaiList.isEmpty) {
      return Text(
        '暂时没有擂台数据',
        style: TextStyle(color: Colors.black),
      );
    }

    return ListView.builder(
      itemCount: leitaiList.length,
      itemBuilder: _buildCard,
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    var item = leitaiList[index];
    if (item.isNormal()) {
      // 普通擂台
      return _buildPlatform(item);
    } else if (item.isEgg()) {
      // 蛋
      return _buildEgg(item);
    } else if (item.isGroup()) {
      // 御灵团战
      return _buildGroup(item);
    } else {
      return Text('异常');
    }
  }

  Widget _buildPlatform(Leitai leitai) {
    return PlatformWidget(
      leitai,
      onTap: () {
        utils.teleport((leitai.latitude) / 1e6, (leitai.longtitude) / 1e6);
      },
    );
  }

  Widget _buildEgg(Leitai leitai) {
    return EggWidget(
      leitai,
      onTap: () {
        utils.teleport(leitai.latitude / 1e6, leitai.longtitude / 1e6);
      },
    );
  }

  Widget _buildGroup(Leitai leitai) {
    return GroupWidget(
      leitai,
      onTap: () {
        utils.teleport(leitai.latitude / 1e6, leitai.longtitude / 1e6);
      },
    );
  }

  @override
  void dispose() {
    manager.close();
    super.dispose();
  }
}
