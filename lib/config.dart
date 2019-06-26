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
final int leitai_distance = 60000;

final String openMultiFlyKey = 'OpenMultiFlyKey';
bool isOpenMultiFly = true;

final List<MockLocation> startList = [
  MockLocation(0, 0), // 我的周围
  MockLocation(39829104, 116280670), // 北京
  MockLocation(34198173, 108816833), // 西安
  MockLocation(30548070, 103930664), // 成都
  MockLocation(30171250, 120047607), // 杭州
  MockLocation(41757996, 123303680), // 沈阳
  MockLocation(22997587, 113105621), // 广州
  MockLocation(25213017, 110232697), // 桂林城区
  MockLocation(29465905, 106425934), // 重庆
  MockLocation(33537961, 116853333), // 宿州
  MockLocation(35865683, 120047607), // 青岛黄岛区
];

final List<MockLocation> endList = [
  MockLocation(0, 0), // 我的周围
  MockLocation(39990273, 116488037),
  MockLocation(34380846, 109092865),
  MockLocation(30773699, 104186096),
  MockLocation(30387092, 120250854),
  MockLocation(41913519, 123552246),
  MockLocation(23208534, 113363800),
  MockLocation(25371328, 110331573),
  MockLocation(29709525, 106641541),
  MockLocation(33815666, 117066193),
  MockLocation(36107369, 120292053),
];
// 选中的稀有妖灵
String selectedDemon = xiyouList[0];

setOpenMultiFly(bool open) async {
  isOpenMultiFly = open;
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool(openMultiFlyKey, open);
}

class Config {
  static init() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    isOpenMultiFly = pref.getBool(openMultiFlyKey);
    if (null == isOpenMultiFly) {
      isOpenMultiFly = true;
    }
    print('isOpenMultiFly = $isOpenMultiFly');
  }
}
