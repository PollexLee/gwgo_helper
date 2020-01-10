import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/manager/token_manager.dart';
import 'package:gwgo_helper/manager/yaoling_manager.dart';
import 'package:gwgo_helper/model/token_model.dart';
import 'package:gwgo_helper/provider/view_state_model.dart';
import 'package:gwgo_helper/ui/scanning/scanning_yaoling/select_yaoling/select_yaoling_page.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:gwgo_helper/utils/dialog_utils.dart';
import 'package:gwgo_helper/yaoling.dart';
import 'package:toast/toast.dart';

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
  // 扫描按钮倒计时
  int delayTime = 10;

  ScanningYaolingViewModel(BuildContext context) {
    this.context = context;
  }

  Future init() async {
    // 将扫描模式默认为 我的周围
    selectedLocation = locationList[1];
    saveLocationRange();
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
    // 页面关闭是，如果还在扫描，就释放token
    if (scanning) {
      scanning = false;
      TokenManager.releaseToken(token);
    }
  }

  void scanningYaoling() async {
    if(startList[1].latitude == -1){
      Toast.show('请先选择扫描位置', context);
      return;
    }
    // 扫描之前，先请求token
    showProgressDialog(context, msg: '请求配置中...', barrierDismissible: false);
    try {
      TokenModel tokenModel = await TokenManager.getTokenForYaoling();
      if (tokenModel.code == '-1') {
        Toast.show('暂时没有可用的配置，请10秒后重试', context, duration: 2);
        dismissProgressDialog(context);
        startDelay();
        return;
      } else {
        tokenModel.publish();
        print('更新token成功, token = ${tokenModel.token}');
      }
    } catch (e) {
      Toast.show('网络异常，稍后重试', context, duration: 1);
      dismissProgressDialog(context);
      print('网络异常，稍后重试');
      return;
    }
    dismissProgressDialog(context);
    Toast.show('开始扫描', context);
    scanning = true;
    allData.clear();
    notifyListeners();
    manager.refreshYaoling((List<Yaoling> data, String process) {
      processString = process;
      if (process.contains("扫描完成")) {
        // 释放token
        TokenManager.releaseToken(token);
        token = "";
        openid = "";
      }
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
    setSelectArea((String data) {
      if (null == data || data.isEmpty) {
        toast('没有选择有效的自定义区域');
        return;
      }
      toast('选择扫描区域成功');
      saveSelectArea(data);
      parseArea(data);
      notifyListeners();
    });
  }

  void startDelay() {
    delayTime--;
    notifyListeners();
    Timer.periodic(Duration(seconds: 1), (timer) {
      delayTime--;
      if (delayTime == 0) {
        delayTime = 10;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  String getDelayTime() {
    return delayTime == 10 ? "" : '（${delayTime.toString()}）';
  }
}
