import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/model/deviceInfo.dart';

import './utils/common_utils.dart';
import './utils/dialog_utils.dart';

/// 用户授权单例
class PromiseInstance {
// imei数据
  List<String> imeiList = List();
  // 网络时间
  int netTime = 0;
  // 我的有效时间
  DeviceInfo _deviceInfo;

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
    // DialogUtils.showProgressDialog(context, '初始化中...');
    // 获取imei
    imeiList = await _getImeiList();
    if (imeiList == null || imeiList.isEmpty) {
      DialogUtils.hideProgressDialog();
      DialogUtils.showPremissionDialog(context);
      return;
    }
    // 通过IMEI请求设备注册信息
    _deviceInfo = await _getMyDeviceInfo(context);
    // 注册信息为空，提示
    if (_deviceInfo == null) {
      DialogUtils.hideProgressDialog();
      DialogUtils.showNetworkErrorDialog(context);
      return;
    }

    // 获取当前网络时间
    netTime = await getNetTime();
    if (netTime <= 0) {
      DialogUtils.hideProgressDialog();
      DialogUtils.showNetworkErrorDialog(context);
      return;
    }

    // 获取我的注册时间
    // myRegisteTime = _getMyRegisteTime();

    // filterMyDeviceInfo(context);
  }

  /// 从网络获取设备信息
  Future<DeviceInfo> _getMyDeviceInfo(BuildContext context) async {
    var dio = Dio();
    dio.options.headers.addAll({'Content-Type': 'application/json'});
    try {
      Response response = await dio
          .get('http://45.78.29.113:8848/getDeviceInfo?imei=${imeiList[0]}');
      print(response.data);
      DeviceInfo deviceInfo = DeviceInfo.fromJson(response.data);
      return deviceInfo;
    } catch (e) {
      print(e);
      return null;
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

    // 获取我的设备信息
    if (_deviceInfo == null) {
      DialogUtils.showProgressDialog(context, "正在获取注册信息...");
      _deviceInfo = await _getMyDeviceInfo(context);
      DialogUtils.hideProgressDialog();
      if (_deviceInfo == null) {
        DialogUtils.showNetworkErrorDialog(context);
        return false;
      }
    }
    // 有效期短语
    if (_deviceInfo.expireTime < netTime) {
      // 到期
      DialogUtils.showRegistDialog(context, imeiList[0], true);
      return false;
    } else {
      // 没到期
      return true;
    }
  }

  Future<List<String>> _getImeiList() async {
    try {
      Map<String, dynamic> imeiMap = await getDeviceImei();
      List<dynamic> temp = imeiMap['imei'];
      imeiList = temp.map<String>((item) {
        return item;
      }).toList();
      if (imeiList == null ||
          imeiList.isEmpty ||
          imeiList[0] == null ||
          imeiList[0] == 'null') {
        return List<String>(0);
      }
      return imeiList;
    } catch (exception) {
      print('获取设备id，异常了 $exception');
      return List<String>(0);
    }
  }

  // _initRegisterList() {

  //   Map<String, int> vipMap = {
  // '358240051111110': 1860700800000,
  // '869285032737089': 1930700800000, // 自己设备
  // 'A00000966CDA2F': 1562239885000 + MONTH_TIME, // 6月29日 ~不懂夜の黑~
  // '99001235131048': 1561824000000, // 6月29日
  // '868179045254391': 1561824000000, // 6月29日
  // 'A000009B43460D': 1561984743000 + WEEK_TIME, // 6月30日 颜校长
  // '861467035410793': 1563033600000, // 7月13日
  // '863976040655372': 1563811200000, // 7月22日 我的士多啤梨
  // '860735036297125': 1563811200000, // 7月22日
  // '865861040042532': 1563811200000, // 7月22日
  // 'A000009D1B75D7': 1563811200000, // 7月22日
  // '990007171061366': 1563811200000, // 7月22日
  // '867601030359290': 1563811200000 + THREE_DAY_TIME, // 7月22日 ;
  // '860746048161092': 1563811200000 + WEEK_TIME, // 7月29日 小主播
  // '864499044361771': 1563811200000, // 7月22日 爱无限
  // '861658048128618': 1563811200000 + WEEK_TIME, // 7月29日 笑摩戈
  // '865140041672880': 1564156800000, // 7月26日
  // '868227044099372': 1562846334000 + WEEK_TIME, // 7月1日  紫毅星辰
  // '860928045715068': 1561478400000 + WEEK_TIME * 3, // 次北安
  // 'A00000873CD710': 1561478400000 + WEEK_TIME, // 没名字 没头像
  // '867520045967253': 1561478400000 + MONTH_TIME, // 车马邮箱
  // '867614043378892': 1562116883000 + MONTH_TIME, // 在线代捉
  // '863505034241657': 1562734676000 + WEEK_TIME, // 迷茫的云
  // '865749038394496': 1561478400000 + MONTH_TIME, // 二号飞行员
  // '862904031088636': 1561478400000 + WEEK_TIME, // 偏爱
  // '865883040063771': 1561651200000 + WEEK_TIME * 2, // 铅笔大人
  // '355757010442537': 1561651200000 + MONTH_TIME, // 安和桥
  // '99001093091401': 1561651200000 + MONTH_TIME + THREE_DAY_TIME, // yun
  // '868240038271626': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
  // 'A0000089B3729A': 1562574997000 + MONTH_TIME, // yun
  // '864758040117358': 1562677332000 + MONTH_TIME, // yun
  // '867684031532792': 1562557536000 + MONTH_TIME, // 孑系子龙
  // '863813047442530': 1562503696000 + MONTH_TIME, // yun
  // '868217038528023': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
  // 'A000009A195687': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
  // '862255038991243': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
  // '862427045237171': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
  // '865964033913592': 1561651200000 + MONTH_TIME + THREE_DAY_TIME, // yun
  // '869456037190158': 1561775248000 + WEEK_TIME, // ✡
  // 'A0000085790C6C': 1561775248000 + MONTH_TIME, // yun
  // '867194048095767': 1561775248000 + WEEK_TIME + MONTH_TIME, // 秋的月
  // '865968032271993': 1562658749000 + MONTH_TIME, // 兰陵不笑生
  // '866400033192506': 1561775248000 + MONTH_TIME + ONE_DAY_TIME, // 列奥纳多.
  // '862495040771056': 1562597267000 + MONTH_TIME, // 捉妖小商
  // '862537037930102': 1561968468000 + MONTH_TIME, // 醉臥美人膝
  // '865579039536682': 1562037513000 + MONTH_TIME, // ���光熹微
  // '867601030359290': 1562055675000 + MONTH_TIME * 2, // ;
  // '867955030534306': 1562140140000 + MONTH_TIME, // 原来你还���这里
  // '861742039637371': 1562159057000 + WEEK_TIME, // yun
  // '869832041816337': 1562168035000 + MONTH_TIME, // qianbi
  // '868734037803298': 1562202490000 + MONTH_TIME, // qianbi
  // '865676033894404': 1562342439000 + WEEK_TIME, // 动心
  // '868030034803963': 1562210049000 + MONTH_TIME, // qianbi
  // '869810034744039': 1562219399000 + MONTH_TIME, // qianbi
  // '862856043482613': 1562219982000 + MONTH_TIME, // qianbi
  // '868233034604734': 1562220681000 + MONTH_TIME, // qianbi
  // '865738030126006': 1562239842000 + MONTH_TIME, // 秋的月 2
  // '99001284335416': 1562253606000 + MONTH_TIME, // 时与.
  // '869189043226019': 1562293444000 + WEEK_TIME, // 三岁奶猫
  // '861945035994403': 1562295172000 + WEEK_TIME, // 琴断弦奈何
  // '868897037623212': 1562303261000 + MONTH_TIME, // qianbi
  // '863295033832173': 1562317321000 + MONTH_TIME, // qianbi
  // '990009269237544': 1562336894000 + MONTH_TIME, // qianbi
  // '866378035770273': 1562342439000 + MONTH_TIME, // 月
  // '860482035999704': 1562342439000 + WEEK_TIME, // 椿风
  // '865441032892747': 1562497821000 + MONTH_TIME, // qianbi
  // '358533080056524': 1562497821000 + MONTH_TIME, // qianbi
  // '861348043044438': 1562551952000 + MONTH_TIME, // qianbi
  // '99001116055291': 1562571856000 + MONTH_TIME, // qianbi
  // '866778033021241': 1562576039000 + MONTH_TIME, // qianbi
  // '867252032118795': 1562582047000 + MONTH_TIME, // Loco
  // '863957042025657': 1562658713000 + MONTH_TIME, // qianbi
  // '869011038242837': 1562659623000 + MONTH_TIME, // qianbi
  // '868179048017233': 1562663252999 + MONTH_TIME, // qianbi
  // '865132035904114': 1562735012000 + MONTH_TIME, // 板蓝根
  // '869037042838500': 1562723672000 + MONTH_TIME, // qianbi
  //   };
  // }

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
    if (_deviceInfo == null) {
      return '设备未注册';
    }
    if (netTime <= 0) {
      return '网络异常，请联网后重启';
    }
    if (_deviceInfo.expireTime < netTime) {
      return '注册已过期';
    } else {
      var format = DateTime.fromMillisecondsSinceEpoch(_deviceInfo.expireTime);
      return '到期时间：${format.year}-${format.month}-${format.day} ${format.hour}:${format.minute}';
    }
  }
}
