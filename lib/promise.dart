import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import './utils/common_utils.dart';
import './utils/dialog_utils.dart';

import 'package:crypto/crypto.dart';

/// 用户授权单例
class PromiseInstance {
// 常量
  final int commonTime = 1561478400000;
  final int MONTH_TIME = 2592000000;
  final int WEEK_TIME = 604800000;
  final int THREE_DAY_TIME = 259200000;
  final int ONE_DAY_TIME = 86400000;

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

    // filterMyDeviceInfo(context);
  }

  filterMyDeviceInfo(BuildContext context) async {
    var dio = Dio();
    int time = DateTime.now().millisecondsSinceEpoch;
    var key = sha1.convert(utf8
        .encode('A6016315668944UZ11F00C29-2866-FC65-D73D-B7120B1A5A57UZ$time'));
    dio.options.headers.addAll({
      'X-APICloud-AppId': 'A6016315668944',
      'X-APICloud-AppKey': '${key.toString()}.$time',
      'Content-Type': 'application/json',
      'authorization':
          'b2cdqvHlVjHuScmCMVkBNSmrt8ZIBW9VowfmN24WzsK5bR9GlZIz6AaW3PODlCDV',
    });
    try {
      Response response = await dio
          .get('https://d.apicloud.com//mcm/api/user/5d1da2f29b93c6453bae99dd');
      print(response.data);
    } catch (e) {
      print(e);
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
      '99000963669917': commonTime,
      '864454033324140': commonTime,
      'A000009EF2F42E': commonTime,
      '865441037037264': commonTime,
      '354268095777418': commonTime,
      '869759037886521': commonTime,
    };

    Map<String, int> vipMap = {
      '358240051111110': 1860700800000,
      '869285032737089': 1930700800000, // 自己设备
      'A00000966CDA2F': 1562239885000 + MONTH_TIME, // 6月29日 ~不懂夜の黑~
      '99001235131048': 1561824000000, // 6月29日
      '868179045254391': 1561824000000, // 6月29日
      'A000009B43460D': 1561984743000 + WEEK_TIME, // 6月30日 颜校长
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
      '867614043378892': 1562116883000 + MONTH_TIME, // 在线代捉
      '863505034241657': 1562734676000 + WEEK_TIME, // 迷茫的云
      '865749038394496': 1561478400000 + MONTH_TIME, // 二号飞行员
      '862904031088636': 1561478400000 + WEEK_TIME, // 偏爱
      '865883040063771': 1561651200000 + WEEK_TIME * 2, // 铅笔大人
      '355757010442537': 1561651200000 + MONTH_TIME, // 安和桥
      '99001093091401': 1561651200000 + MONTH_TIME + THREE_DAY_TIME, // 云
      '868240038271626': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      'A0000089B3729A': 1562574997000 + MONTH_TIME, // yun
      '864758040117358': 1562677332000 + MONTH_TIME, // yun
      '867684031532792': 1562557536000 + MONTH_TIME, // 孑系子龙
      '863813047442530': 1562503696000 + MONTH_TIME, // yun
      '868217038528023': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      'A000009A195687': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '862255038991243': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '862427045237171': 1561651200000 + WEEK_TIME + THREE_DAY_TIME, // yun
      '865964033913592': 1561651200000 + MONTH_TIME + THREE_DAY_TIME, // yun
      '869456037190158': 1561775248000 + WEEK_TIME, // ✡
      'A0000085790C6C': 1561775248000 + MONTH_TIME, // yun
      '867194048095767': 1561775248000 + WEEK_TIME + MONTH_TIME, // 秋的月
      '865968032271993': 1562658749000 + MONTH_TIME, // 兰陵不笑生
      '866400033192506': 1561775248000 + MONTH_TIME + ONE_DAY_TIME, // 列奥纳多.
      '862495040771056' : 1562597267000 + MONTH_TIME, // 捉妖小商
      '862537037930102': 1561968468000 + MONTH_TIME, // 醉臥美人膝
      '865579039536682': 1562037513000 + MONTH_TIME, // 晨光熹微
      '867601030359290': 1562055675000 + MONTH_TIME * 2, // ;
      '867955030534306': 1562140140000 + MONTH_TIME, // 原来你还在这里
      '861742039637371': 1562159057000 + WEEK_TIME, // yun
      '869832041816337': 1562168035000 + MONTH_TIME, // qianbi
      '868734037803298': 1562202490000 + MONTH_TIME, // qianbi
      '865676033894404': 1562342439000 + WEEK_TIME, // 动心
      '868030034803963': 1562210049000 + MONTH_TIME, // qianbi
      '869810034744039': 1562219399000 + MONTH_TIME, // qianbi
      '862856043482613': 1562219982000 + MONTH_TIME, // qianbi
      '868233034604734': 1562220681000 + MONTH_TIME, // qianbi
      '865738030126006': 1562239842000 + MONTH_TIME, // 秋的月 2
      '99001284335416': 1562253606000 + MONTH_TIME, // 时与.
      '869189043226019': 1562293444000 + WEEK_TIME, // 三岁奶猫
      '861945035994403': 1562295172000 + WEEK_TIME, // 琴断弦奈何
      '868897037623212': 1562303261000 + MONTH_TIME, // qianbi
      '863295033832173': 1562317321000 + MONTH_TIME, // qianbi
      '990009269237544': 1562336894000 + MONTH_TIME, // qianbi
      '866378035770273': 1562342439000 + MONTH_TIME, // 月
      '860482035999704': 1562342439000 + WEEK_TIME, // 椿风
      '865441032892747': 1562497821000 + MONTH_TIME, // qianbi
      '358533080056524': 1562497821000 + MONTH_TIME, // qianbi
      '861348043044438': 1562551952000 + MONTH_TIME, // qianbi
      '99001116055291': 1562571856000 + MONTH_TIME, // qianbi
      '866778033021241' : 1562576039000 + MONTH_TIME, // qianbi
      '867252032118795' : 1562582047000 + MONTH_TIME, // Loco
      '863957042025657' : 1562658713000 + MONTH_TIME, // qianbi
      '869011038242837' : 1562659623000 + MONTH_TIME, // qianbi
      '868179048017233' : 1562663252999 + MONTH_TIME, // qianbi
      '865132035904114' : 1562735012000 + MONTH_TIME, // 板蓝根
      '869037042838500' : 1562723672000 + MONTH_TIME, // qianbi
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
    if (myRegisteTime <= 0) {
      return '设备未注册';
    }
    if (netTime <= 0) {
      return '网络异常，请联网后重启';
    }
    if (myRegisteTime < netTime) {
      return '注册已过期';
    } else {
      var format = DateTime.fromMillisecondsSinceEpoch(myRegisteTime);
      return '到期时间：${format.year}-${format.month}-${format.day} ${format.hour}:${format.minute}';
    }
  }
}
