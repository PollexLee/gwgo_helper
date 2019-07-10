import 'package:gwgo_helper/yaoling.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/location.dart';

final List<String> xiyouList = [
  '我的周围',
  '北京',
  '西安',
  '成都',
  '杭州',
  '沈阳',
  '广州',
  '桂林城区',
  '重庆',
  '宿州',
  '青岛',
];

/// 我的周围 距离
final int distance = 40000;
final int stemp = 20000;
final int leitai_distance = 140000;

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
  MockLocation(39700847, 116109009), // 北京
  MockLocation(34198173, 108816833), // 西安
  MockLocation(30548070, 103930664), // 成都
  MockLocation(30171250, 120047607), // 杭州
  MockLocation(41757996, 123303680), // 沈阳
  MockLocation(22997587, 113105621), // 广州
  MockLocation(25213017, 110232697), // 桂林城区
  MockLocation(29465905, 106425934), // 重庆
  MockLocation(33537961, 116853333), // 宿州
  // MockLocation(35865683, 120047607), // 青岛黄岛区
  MockLocation(35882931, 120037308), // 青岛黄岛区
];

final List<MockLocation> endList = [
  MockLocation(0, 0), // 我的周围
  MockLocation(40199855, 116685791),
  MockLocation(34380846, 109092865),
  MockLocation(30773699, 104186096),
  MockLocation(30387092, 120250854),
  MockLocation(41913519, 123552246),
  MockLocation(23208534, 113363800),
  MockLocation(25371328, 110331573),
  MockLocation(29709525, 106641541),
  MockLocation(33815666, 117066193),
  // MockLocation(36107369, 120292053),
  MockLocation(36465472, 120717773),
];
// 选中的
String selectedDemon = xiyouList[0];

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
  pref.setString(locationKey, selectedDemon);
}

class Config {
  static init() async {
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
    selectedDemon = pref.getString(locationKey);
    if (null == selectedDemon) {
      selectedDemon = xiyouList[0];
    }
    // 初始化 自动启动游戏
    isStartAir = pref.getBool(startAirKey);
    if (null == isStartAir) {
      isStartAir = true;
    }
  }
}
