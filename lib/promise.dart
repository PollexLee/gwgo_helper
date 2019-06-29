import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import './utils/common_utils.dart';

final int commonTime = 1561478400000;

final int MONTH_TIME = 2592000000;
final int WEEK_TIME = 604800000;
final int THREE_DAY_TIME = 259200000;

Map<String, int> currentMap = Map();

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
  '869285032737089': 1860700800000, // 自己设备
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
};

/// 是否授权
isPromise() {
  currentMap.clear();
  currentMap.addAll(registMap);
  currentMap.addAll(vipMap);

  Future<Map<String, dynamic>> imeiMap = getDeviceImei();
  imeiMap.catchError((onError) async {
    await toast('请授予<获取手机信息>权限');
    print('获取设备id，异常了');
    Timer.periodic(Duration(seconds: 2), (timer) {
      exit(0);
    });
  });
  imeiMap.then((imeis) async {
    List<dynamic> imeiList = imeis['imei'];
    print('imeiList = $imeiList');
    for (String item in currentMap.keys) {
      if (imeiList.contains(item)) {
        // imei已注册，判断时间
        if (await isTimePromise(currentMap[item])) {
          return;
        } else {
          await toast('已过有效期，请咨询QQ群：162411670');
          Timer.periodic(Duration(seconds: 2), (timer) {
            exit(0);
          });
          return;
        }
      }
    }
    Clipboard.setData(ClipboardData(text: imeiList[0]));
    await toast('此设备没有绑定，请咨询QQ群：162411670');
    Timer.periodic(Duration(seconds: 2), (timer) {
      exit(0);
    });
  });
}

/// 时间有效期判断
Future<bool> isTimePromise(int promiseTime) async {
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
    return timestemp < promiseTime;
  } catch (exception) {
    print(exception);
    await toast('请联网后启动飞行指示器');
    Timer.periodic(Duration(seconds: 2), (timer) {
      exit(0);
    });
    return true;
  }
}
