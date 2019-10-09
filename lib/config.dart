import 'package:flutter/material.dart';
import 'package:gwgo_helper/promise.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:gwgo_helper/utils/dialog_utils.dart';
import 'package:gwgo_helper/yaoling.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/location.dart';

var token = "";
var openid = "";

final List<String> plainList = [
  '自带飞行器',
  '咬她的飞行器',
  '小主播的飞行器',
  '小莫哥的飞行器',
];

String IS_FIRST_START_KEY = 'isFirstStartKey';
bool isFirstStart = true;
saveFirstStart(bool b) async {
  isFirstStart = b;
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool(IS_FIRST_START_KEY, b);
}

final String plainKey = 'plainKey';
String selectPlain = plainList[0];

/// 保存选择的飞行器
saveSelectPlain() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(plainKey, selectPlain);
}

final List<String> locationList = [
  '我的周围',
  '自定义区域',
  '北京',
  '西安',
  '成都',
  '杭州',
  '沈阳',
  '广州',
  '南京',
];

/// 我的周围 距离
final int distance = 40000;
final int stemp = 20000;
final int leitai_distance = 400000;

final String yaolingRangeKey = 'YaolingRangeKey';
String rangeSelect = '小';
final List<String> rangeList = ['极小', '小', '中', '大'];

// 点击过的妖灵数据
List<Yaoling> clickYaolingData = List();

final String openMultiFlyKey = 'OpenMultiFlyKey';
bool isOpenMultiFly = true;
final String openFlyKey = 'OpenFlyKey';
bool isOpenFly = true;
final String startAirKey = 'startAirKey';
bool isStartAir = true;

final String locationKey = 'LocationKey';
final List<MockLocation> startList = [
  MockLocation(0, 0), // 我的周围
  MockLocation(-1, -1), // 自定义区域
  MockLocation(39700847, 116109009), // 北京
  MockLocation(34198173, 108816833), // 西安
  MockLocation(30548070, 103930664), // 成都
  MockLocation(30171250, 120047607), // 杭州
  MockLocation(41757996, 123303680), // 沈阳
  MockLocation(22997587, 113105621), // 广州
  MockLocation(31907873, 118543854), // 南京
];

final List<MockLocation> endList = [
  MockLocation(0, 0), // 我的周围
  MockLocation(-1, -1), // 自定义区域
  MockLocation(40199855, 116685791),
  MockLocation(34380846, 109092865),
  MockLocation(30773699, 104186096),
  MockLocation(30387092, 120250854),
  MockLocation(41913519, 123552246),
  MockLocation(23208534, 113363800),
  MockLocation(32349803, 118957214),
];

// 自定区域
String SELECT_AREA_KEY = 'select_area_key';
saveSelectArea(String area) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(SELECT_AREA_KEY, area);
}

parseArea(String area) {
  List<String> array = area.split('|');
  var minList = array[0].split(',');
  var maxList = array[1].split(',');
  // 把经纬度，转换成对应格式复制给自定义位置 数据
  startList[1].latitude = (double.parse(minList[0]) * 1e6).toInt();
  startList[1].longitude = (double.parse(minList[1]) * 1e6).toInt();
  endList[1].latitude = (double.parse(maxList[0]) * 1e6).toInt();
  endList[1].longitude = (double.parse(maxList[1]) * 1e6).toInt();
}

/// 是否起飞
bool isFly = false;
String isFlyKey = "isFlyKey";
saveFlyStatus() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool(isFlyKey, isFly);
}

/// 是否显示摇杆
bool isShowRocker = false;
String ROCKER_KEY = "ROCKER_KEY";
saveRockerStatus() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool(ROCKER_KEY, isShowRocker);
}

String lastLocationString = '';
String LAST_LOCATION_KEY = 'LAST_LOCATION_KEY';
setLocation(String locationStr) async {
  lastLocationString = locationStr;
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(LAST_LOCATION_KEY, lastLocationString);
}

// 选中的位置
String selectedLocation = locationList[0];

setStartAir(bool open) async {
  isStartAir = open;
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool(startAirKey, open);
}

setOpenMultiFly(bool open) async {
  isOpenMultiFly = open;
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool(openMultiFlyKey, open);
}

setOpenFly(bool open) async {
  isOpenFly = open;
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool(openFlyKey, open);
}

/// 保存妖灵扫描范围数据
saveYaolingRange() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(yaolingRangeKey, rangeSelect);
}

/// 保存选择扫描位置数据
saveLocationRange() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(locationKey, selectedLocation);
}

class Config {
  static init(BuildContext context) async {
    // 初始化 多次飞行
    SharedPreferences pref = await SharedPreferences.getInstance();
    isOpenMultiFly = pref.getBool(openMultiFlyKey);
    if (null == isOpenMultiFly) {
      isOpenMultiFly = true;
    }
    print('isOpenMultiFly = $isOpenMultiFly');
    // 初始化 开启飞行
    isOpenFly = pref.getBool(openFlyKey);
    if (null == isOpenFly) {
      isOpenFly = true;
    }
    print('isOpenFly = $isOpenFly');
    // 初始化 扫描范围
    rangeSelect = pref.getString(yaolingRangeKey);
    if (null == rangeSelect) {
      rangeSelect = '小';
    }
    // 初始化 已选择妖灵
    selectedLocation = pref.getString(locationKey);
    if (null == selectedLocation) {
      selectedLocation = locationList[0];
    }
    // 初始化 自动启动游戏
    isStartAir = pref.getBool(startAirKey);
    if (null == isStartAir) {
      isStartAir = true;
    }
    // 初始化 选择
    selectPlain = pref.getString(plainKey);
    if (null == selectPlain) {
      selectPlain = plainList[0];
    }

    lastLocationString = pref.getString(LAST_LOCATION_KEY);
    if (null == lastLocationString) {
      lastLocationString = "";
    }

    isFly = pref.getBool(isFlyKey);
    if (null == isFly) {
      isFly = false;
    }
    // isFly = isStart;

    isShowRocker = pref.getBool(ROCKER_KEY);
    if (null == isShowRocker) {
      isShowRocker = false;
    }

    isFirstStart = pref.getBool(IS_FIRST_START_KEY);
    if (null == isFirstStart) {
      isFirstStart = true;
    }

    if (isFirstStart) {
      saveFirstStart(false);
      DialogUtils.showPremissionDialog(context, () {
        PromiseInstance(context).init(context);
        Navigator.pushNamed(context, '/help');
      });
    }

    // 初始化 自定义区域数值
    var area = pref.getString(SELECT_AREA_KEY);
    if (null != area && area.isNotEmpty) {
      parseArea(area);
    }
  }
}
