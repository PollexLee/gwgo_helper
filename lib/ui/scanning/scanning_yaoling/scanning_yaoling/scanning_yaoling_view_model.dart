import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/manager/yaoling_manager.dart';
import 'package:gwgo_helper/provider/view_state_model.dart';
import 'package:gwgo_helper/ui/scanning/scanning_yaoling/select_yaoling/select_yaoling_page.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:gwgo_helper/utils/dialog_utils.dart';
import 'package:gwgo_helper/yaoling.dart';

class ScanningYaolingViewModel extends ViewStateModel {
  YaolingManager manager;
  bool isCreate = false;

  final GlobalKey<ScaffoldState> key = GlobalKey();

  /// 所有扫描到的妖灵数组
  List<Yaoling> allData = List();

  /// 显示的妖灵数组
  // List<Yaoling> yaolingData = List();

  String processString = '';

  bool scanning = false;

  ScanningYaolingViewModel(BuildContext context) {
    this.context = context;
  }

  Future init() async {
    manager = YaolingManager();
    manager.init((int status) {
      if (status == 0 && !isCreate) {
        isCreate = true;
        // _refreshYaoling();
      } else if (status == 1) {
        manager.close();
      }
    });
  }

  /// 关闭扫描
  void closeScanning() {
    if (null != manager) {
      manager.close();
    }
  }

  void scanningYaoling()async {
    // 扫描之前，先请求token
    showProgressDialog(context, msg: '请求配置中...');
    var dio = Dio();
    dio.options.headers.addAll({'Content-Type': 'application/json'});
    dio.options.receiveTimeout = 60000;
    try {
      // 从服务端获取token，可以延迟
      Response response = await dio
          .get('http://gwgo.pollex.me:8848/getAuth?imei=${imeiList[0]}');

    } catch (e) {
      print(e);
    }
    dismissProgressDialog(context);
    scanning = true;
    allData.clear();
    notifyListeners();
    manager.refreshYaoling((List<Yaoling> data, String process) {
      processString = process;
      if (process == "扫描完成") {}
      if (data == null) {
      } else if (data.isNotEmpty) {
        // 添加到数据中
        Color color = Colors.white;
        data.forEach((item) {
          // 判断所有的数据中是否已包含此个，不包含，才加入到列表中
          if (!allData.contains(item)) {
            allData.add(item);
            // 判断当前是否已经点击过了，点击过了，就设置isClick = true
            if (!item.isClick && clickYaolingData.contains(item)) {
              item.isClick = true;
            }
            item.color = color;
          }
        });
      }
      notifyListeners();
    });
  }

  void openSetting() async {
    await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return SelectYaolingPage();
    }));
    notifyListeners();
  }

  void openSelectPosition() {
    selectedLocation = locationList[1];
    saveLocationRange();
    setSelectArea((String data) {
      if (null == data || data.isEmpty) {
        toast('没有选择有效的自定义区域');
        return;
      }
      toast('选择扫描区域成功');
      saveSelectArea(data);
      parseArea(data);
    });
  }
}
