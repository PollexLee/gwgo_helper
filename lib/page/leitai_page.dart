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
  int index = 2;
  /// 团战
  static int GROUP_INDEX = 1;
  /// 擂台
  static int  LEITAI_INDEX = 2;
  String name = "";


  LeitaiPage(this.index,{this.name});

  @override
  State<StatefulWidget> createState() {
    return LeitaiState();
  }
}

class LeitaiState extends State<LeitaiPage> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  // var buttonText = '扫描稀有';
  List<Leitai> leitaiList = List();
  LeitaiManager manager;

  int _getLeitaiType(int index) {
    if (index == 2) {
      return LEITAI_TYPE_GROUP;
    } else if (index == 3) {
      return LEITAI_TYPE_NORMAL;
    }
  }

  @override
  void initState() {
    // 在initState 执行完成之前，无法调用此方法
    // index = ModalRoute.of(context).settings.arguments;
    manager = LeitaiManager();
    manager.init((int status) {
      if (status == 0) {
        _refreshLeitai();
      } else if (status == 1) {
        manager.close();
        // setState(() {
        //   buttonText = '扫描结束';
        // });
      }
    });
    super.initState();
  }

  void _refreshLeitai() {
    manager.refreshLeitai((List<Leitai> data) {
      if (data.isNotEmpty) {
        // if (leitaiList.length > 100) {
        //   key.currentState.showSnackBar(SnackBar(
        //     content: Text('擂台数量已大于100，不再添加'),
        //   ));
        //   return;
        // }
        data.forEach((leitai) {
          if (_getLeitaiType(widget.index) == LEITAI_TYPE_NORMAL &&
              leitai.isNormal()) {
            leitaiList.add(leitai);
          } else if (_getLeitaiType(widget.index) == LEITAI_TYPE_GROUP &&
              leitai.isGroup()) {
            leitaiList.add(leitai);
          }
        });

        if (_getLeitaiType(widget.index) == LEITAI_TYPE_NORMAL) {
          leitaiList.sort((left, right) =>
              right.winner_fightpower.compareTo(left.winner_fightpower));
        }
        setState(() {});
      }
    });
    // if (connectStatus != 2) {
    //   key.currentState.showSnackBar(SnackBar(
    //     content: Text('请等连接成功后再扫描'),
    //   ));
    //   return;
    // }
    // setState(() {
    //   leitaiList.clear();
    //   buttonText = '扫描中';
    // });
    // key.currentState.showSnackBar(SnackBar(
    //   content: Text('开始扫描'),
    // ));
    // _radarSocket.refresh((List<Leitai> data) {
    //   if (data == null) {
    //     key.currentState.showSnackBar(SnackBar(
    //       content: Text('扫描结束'),
    //     ));
    //     setState(() {
    //       buttonText = '扫描结束，点击重新开始扫描';
    //     });
    //   } else if (data.isNotEmpty) {
    //     key.currentState.showSnackBar(SnackBar(
    //       content: Text('此处有${data.length}个五级擂台'),
    //     ));
    //     setState(() {
    //       leitaiList.addAll(data);
    //       // 按照战力排序
    //       if (_getLeitaiType(widget.index) == LEITAI_TYPE_NORMAL) {
    //         leitaiList.sort((left, right) =>
    //             left.getYaolingPower().compareTo(right.getYaolingPower()));
    //       }
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text('三环内五星擂台'),
      ),
      body: _buildBody(leitaiList),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _connect,
      //   tooltip: 'Connect',
      //   child: _buildFloatActionButton(connectStatus),
      //   backgroundColor: _buildFloatActionButtonColor(connectStatus),
      // ),
    );
  }

  Widget _buildBody(List<Leitai> leitaiList) {
    if (null == leitaiList || leitaiList.isEmpty) {
      return Text(
        '暂时没有擂台数据',
        style: TextStyle(color: Colors.black),
      );
    }

    return ListView(
      children: _buildCards(leitaiList),
    );
  }

  List<Widget> _buildCards(List<Leitai> leitaiList) {
    List<Widget> widgetList = List();
    leitaiList.forEach((item) {
      // 构建三种擂台的View
      if (item.isNormal()) {
        // 普通擂台
        widgetList.add(_buildPlatform(item));
      } else if (item.isEgg()) {
        // 蛋
        widgetList.add(_buildEgg(item));
      } else if (item.isGroup()) {
        // 御灵团战
        widgetList.add(_buildGroup(item));
      }
    });

    return widgetList;
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
