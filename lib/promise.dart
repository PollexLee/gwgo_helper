import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import './utils/common_utils.dart';
import './utils/dialog_utils.dart';

/// 用户授权单例
class PromiseInstance {
// 常量
  final int commonTime = 1561478400000;
  final int MONTH_TIME = 2592000000;
  final int WEEK_TIME = 604800000;
  final int THREE_DAY_TIME = 259200000;
// imei数据
  List<String> imeiList = List();
  // 网络时间
  int netTime = 0;
  // 我的有效时间
  int myRegisteTime = 0;

  Map<String, int> currentMap = Map();

  Timer netTimeTimer;

  factory PromiseInstance(BuildContext context) => _promiseInstance(context);
  static PromiseInstance _instance;
  PromiseInstance._(BuildContext context) {
    _init(context);
  }

  static PromiseInstance _promiseInstance(BuildContext context) {
    if (null == _instance) {
      return _instance = PromiseInstance._(context);
    } else {
      return _instance;
    }
  }

  /// 初始化所有数据, 有问题 弹窗提示
  _init(BuildContext context) async {
    // 组建注册list
    _initRegisterList();
    // 获取imei
    imeiList = await _getImeiList();
    if (imeiList == null || imeiList.isEmpty) {
      DialogUtils.showPremissionDialog(context);
      return;
    }
    // 获取我的注册时间
    myRegisteTime = _getMyRegisteTime();

    // 获取当前网络时间
    netTime = await getNetTime();
    if (netTime <= 0) {
      DialogUtils.showNetworkErrorDialog(context);
      return;
    }
  }

  /// 是否通过权限校验
  Future<bool> isPromise(BuildContext context) async {
    // 判断是否获取到了IMEI
    if (imeiList == null || imeiList.isEmpty) {
      imeiList = await _getImeiList();
    }
    if (imeiList == null || imeiList.isEmpty) {
      DialogUtils.showPremissionDialog(context);
      return false;
    }
    //判断是否获取到网络时间
    if (netTime <= 0) {
      netTime = await getNetTime();
    }
    if (netTime <= 0) {
      DialogUtils.showNetworkErrorDialog(context);
      return false;
    }

    // 获取我注册的时间
    myRegisteTime = _getMyRegisteTime();
    if (myRegisteTime == 0) {
      // 没有注册
      DialogUtils.showRegistDialog(context, imeiList[0], false);
      return false;
    } else {
      if (myRegisteTime < netTime) {
        // 到期
        DialogUtils.showRegistDialog(context, imeiList[0], true);
        return false;
      } else {
        // 没到期
        return true;
      }
    }
  }

  /// 获取我注册时的时间 没有注册返回0
  int _getMyRegisteTime() {
    if (imeiList == null || imeiList.isEmpty) {
      return 0;
    }
    int myRetisteTime = 0;
    imeiList.forEach((item) {
      if (currentMap.keys.contains(item)) {
        myRetisteTime = currentMap[item];
      }
    });
    return myRetisteTime;
  }

  Future<List<String>> _getImeiList() async {
    try {
      Map<String, dynamic> imeiMap = await getDeviceImei();
      List<dynamic> temp = imeiMap['imei'];
      imeiList = temp.map<String>((item) {
        return item;
      }).toList();
      return imeiList;
    } catch (exception) {
      print('获取设备id，异常了 $exception');
      return List<String>(0);
    }
  }

  _initRegisterList() {
    Map<String, int> registMap = {
      '860005048327009': commonTime,
      '864723048059234': commonTime,
      '865413032527870': commonTime,
      '869705034700777': commonTime,
      '354765088983929': commonTime,
      '861608042620979': commonTime,
      '863175042352415': commonTime,
      '868580047897212': commonTime,
      '861945035994403': commonTime,
      '99000963669917': commonTime,
      '864454033324140': commonTime,
      'A000009EF2F42E': commonTime,
      '865441037037264': commonTime,
      '354268095777418': commonTime,
      '869759037886521': commonTime,
    };

    Map<String, int> vipMap = {
      '358240051111110': 1860700800000,
      // '869285032737089': 1860700800000, // 自己设备
      'A00000966CDA2F': 1561824000000, // 6月29日 ~不懂夜の黑~
      '99001235131048': 1561824000000, // 6月29日
      '868179045254391': 1561824000000, // 6月29日
      'A000009B43460D': 1561910400000, // 6月30日 颜校长
      '861467035410793': 1563033600000, // 7月13日
      '863976040655372': 1563811200000, // 7月22日 我的士多啤梨
      '860735036297125': 1563811200000, // 7月22日
      '865861040042532': 1563811200000, // 7月22日
      'A000009D1B75D7': 1563811200000, // 7月22日
      '990007171061366': 1563811200000, // 7月22日
      '867601030359290': 1563811200000 + THREE_DAY_TIME, // 7月22日 ;
      '860746048161092': 1563811200000 + WEEK_TIME, // 7月29日 小主播
      '864499044361771': 1563811200000, // 7月22日 爱无限
      '861658048128618': 1563811200000 + WEEK_TIME, // 7月29日 笑摩戈
      '865140041672880': 1564156800000, // 7月26日
      '868227044099372': 1561392000000 + WEEK_TIME, // 7月1日  紫毅星辰
      '860928045715068': 1561478400000 + WEEK_TIME * 3, // 次北安
      'A00000873CD710': 1561478400000 + WEEK_TIME, // 没名字 没头像
      '867520045967253': 1561478400000 + MONTH_TIME, // 车马邮箱
      '867614043378892': 1561478400000 + WEEK_TIME, // 在线代捉
      '863505034241657': 1561478400000 + WEEK_TIME, // 迷茫的云
      '865749038394496': 1561478400000 + MONTH_TIME, // 二号飞行员
      '862904031088636': 1561478400000 + WEEK_TIME, // 偏爱
      '865883040063771': 1561651200000 + WEEK_TIME, // 铅笔大人
      '355757010442537': 1561651200000 + MONTH_TIME, // 安和桥
      '99001093091401': 1561651200000 + MONTH_TIME + THREE_DAY_TIME, // 云
      '868240038271626': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      'A0000089B3729A': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '864758040117358': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '867684031532792': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '863813047442530': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '868217038528023': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      'A000009A195687': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '862255038991243': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '862427045237171': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '865964033913592': 1561651200000 + MONTH_TIME + THREE_DAY_TIME, // yun
      '869456037190158': 1561775248000 + WEEK_TIME, // ✡
      'A0000085790C6C': 1561775248000 + MONTH_TIME, // yun
      '867194048095767': 1561775248000 + WEEK_TIME, // 秋的月
      '865968032271993': 1561775248000 + WEEK_TIME, // yun
      '866400033192506': 1561775248000 + MONTH_TIME, // 列奥纳多.
      '862495040771056': 1561824417000 + WEEK_TIME, // yun
      '862537037930102': 1561968468000 + MONTH_TIME, // 醉臥美人膝
    };

    currentMap.addAll(vipMap);
    currentMap.addAll(registMap);
  }

  /// 获取网络时间，有时间
  Future<int> getNetTime() async {
    if (netTime > 0) {
      return netTime;
    } else {
      Dio dio = Dio();
      dio.options.responseType = ResponseType.json;
      try {
        Response response = await dio.get(
            'https://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp');
        Map<String, dynamic> result = response.data;
        print(result);
        Map<String, dynamic> data = result['data'];
        int timestemp = int.parse(data['t']);
        print('timestemp = $timestemp');
        this.netTime = timestemp;
        if (null != netTimeTimer) {
          netTimeTimer.cancel();
          netTimeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
            netTime += 1000;
          });
        }
        return timestemp;
      } catch (exception) {
        print(exception);
        return 0;
      }
    }
  }

  /// 获取有效期相关提示
  String getLastTime() {
    if (netTime <= 0) {
      return '网络异常，请联网后重启';
    }
    if (myRegisteTime <= 0) {
      return '设备未注册';
    }
    if (myRegisteTime < netTime) {
      return '注册已过期';
    } else {
      var format = DateTime.fromMillisecondsSinceEpoch(myRegisteTime);
      return '到期时间：${format.year}-${format.month}-${format.day} ${format.hour}:${format.minute}';
    }
  }
}
