import 'package:shared_preferences/shared_preferences.dart';

import 'model/yaoling.dart';

class SpriteConfig {
  /// 稀有妖灵
  // static Map<int, String> spriteMap = Map();

  /// 星宿妖灵
  // static Map<int, String> starMap = Map();

  /// 元素妖灵
  // static Map<int, String> elementMap = Map();

  /// 人生赢家妖灵
  // static Map<int, String> winnerMap = Map();

  /// 鲲妖灵
  // static Map<int, String> shipMap = Map();

  /// 全员恶人
  // static Map<int, String> erenMap = Map();

  /// 地域妖灵
  // static Map<int, String> locationMap = Map();

  /// 巢穴妖灵
  // static Map<int, String> nestMap = Map();

// 选中的妖灵，用于匹配返回的数据
  static List<int> selectedMap = List();

  /// 未知的妖灵集合
  static Map<int, String> unknownMap = Map();

  static final String cacheKey = 'selectedKey';

  static init() async {
    /// 可用于初始化未知的妖灵
    // unknownMap[2004013] = '暴走小龙虾';

    selectedMap.clear();
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> idList = pref.getStringList(cacheKey);

    if (null == idList || idList.isEmpty) {
      // 默认选中银角、风雪虎
      // selectedMap[2000313] = spriteMap[2000313];
      // selectedMap[2000106] = spriteMap[2000106];
    } else {
      idList.forEach((id) {
        selectedMap.add(int.parse(id));
      });
    }
  }

  static toggle(Yaoling yaoling) {
    if (selectedMap.contains(yaoling.Id)) {
      selectedMap.remove(yaoling.Id);
    } else {
      selectedMap.add(yaoling.Id);
    }
    SharedPreferences.getInstance().then((instance) {
      List<String> idStringList = List();
      selectedMap.forEach((id) => idStringList.add(id.toString()));
      instance.setStringList(cacheKey, idStringList);
    });
  }
}
