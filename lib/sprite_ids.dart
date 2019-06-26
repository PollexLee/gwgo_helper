import 'package:shared_preferences/shared_preferences.dart';

import 'model/yaoling.dart';

class SpriteConfig {
  /// 稀有妖灵
  static Map<int, String> spriteMap = Map();

  /// 地域妖灵
  static Map<int, String> locationMap = Map();

  /// 巢穴妖灵
  static Map<int, String> nestMap = Map();

// 选中的妖灵，用于匹配返回的数据
  static Map<int, String> selectedMap = Map();

  static Map<int, String> spriteAllMap = Map();

  static final String cacheKey = 'selectedKey';

  static init() async {
    spriteMap[2000106] = '风雪虎';
    spriteMap[2000317] = '金角小妖';
    spriteMap[2000313] = '银角小妖';
    spriteMap[2000327] = '小蝙蝠';
    spriteMap[2000265] = '香玉';
    spriteMap[2000238] = '颜如玉';
    spriteMap[2000147] = '檐上喵';
    spriteMap[2000188] = 'coco熊';
    spriteMap[2000019] = '金灵';
    spriteMap[2000031] = '银灵';
    spriteMap[2000268] = '白秋练';
    spriteMap[2000404] = '许愿星';
    spriteMap[2000419] = '羊';

    spriteMap[2000518] = '企鹅';
    spriteMap[2004016] = '素包';
    spriteMap[2000109] = '螺莉莉';
    spriteMap[2000028] = '小蝌蚪';
    spriteMap[2000241] = '猫头鹰';
    spriteMap[2000007] = '树树鼠';
    spriteMap[2000040] = '羊秀才';
    spriteMap[2000034] = '水龟';
    spriteMap[2000203] = '丹炉';
    spriteMap[2000271] = '虚灵灵';
    spriteMap[2000272] = '抱抱扑';
    spriteMap[2000513] = '水元宝宝';
    spriteMap[2000197] = '小安康';
    spriteMap[2000247] = '小狐狸';
    spriteMap[2000156] = '小猪仔';
    spriteMap[2000075] = '犀牛';
    spriteMap[2000173] = '螃蟹';
    spriteMap[2004019] = '蟹斗眼';
    spriteMap[2000416] = '围巾蛇';
    // spriteMap[2000406] = '不认识';
    spriteMap[2000422] = '不认识';
    spriteMap[2000401] = '井';
    spriteMap[2000402] = '鬼';
    spriteMap[2000403] = '极';

    nestMap[2000112] = '雷童子';
    nestMap[2000321] = '木偶娃娃';
    nestMap[2000324] = '瓷偶娃娃';
    nestMap[2000413] = '棉袄狼';

    locationMap[2000182] = '小兵俑';
    locationMap[2000206] = '麻辣小火锅';
    locationMap[2004004] = '小白蛇';
    locationMap[2004007] = '貂宝';
    locationMap[2004010] = '舞狮';
    locationMap[2004013] = '暴走小龙虾';

    selectedMap.clear();
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> idList = pref.getStringList(cacheKey);
    if (null == idList || idList.isEmpty) {
      selectedMap.addAll(spriteMap);
      selectedMap.addAll(locationMap);
      selectedMap.addAll(nestMap);
    } else {
      idList.forEach((id) {
        selectedMap[int.parse(id)] = _getName(int.parse(id));
      });
    }
  }

  static String _getName(int id) {
    if (spriteMap.containsKey(id)) {
      return spriteMap[id];
    } else if (locationMap.containsKey(id)) {
      return locationMap[id];
    } else if (nestMap.containsKey(id)) {
      return nestMap[id];
    } else {
      return '未知';
    }
  }

  static toggle(Yaoling yaoling) {
    if (selectedMap.containsKey(yaoling.Id)) {
      selectedMap.remove(yaoling.Id);
    } else {
      selectedMap[yaoling.Id] = yaoling.Name;
    }
    SharedPreferences.getInstance().then((instance) {
      List<int> idList = List.from(selectedMap.keys);
      List<String> idStringList = List();
      idList.forEach((id) => idStringList.add(id.toString()));
      instance.setStringList(cacheKey, idStringList);
    });
  }

  static initAllMap() {
    spriteAllMap[2000003] = '干将';
    spriteAllMap[2000006] = '大碗宽面';
    spriteAllMap[2000009] = '松鼠';
    spriteAllMap[2000015] = '鹿';
    spriteAllMap[2000021] = '金灵';
    spriteAllMap[2000024] = '霸波儿奔';
    spriteAllMap[2000027] = '奔波儿霸';
    spriteAllMap[2000030] = '青蛙';
    spriteAllMap[2000033] = '银灵';
    spriteAllMap[2000036] = '龟丞相';
    spriteAllMap[2000039] = '火龟';
    spriteAllMap[2000042] = '山羊';
    spriteAllMap[2000049] = '大象';
    spriteAllMap[2000057] = '狮子';
    spriteAllMap[2000060] = '九尾';
    spriteAllMap[2000063] = '山毛毛';
    spriteAllMap[2000077] = '水牛';
    spriteAllMap[2000080] = '二觉布鲁';
    spriteAllMap[2000089] = '御三家狮子';
    spriteAllMap[2000092] = '鬼女';
    spriteAllMap[2000102] = '御三家小鸟';
    spriteAllMap[2000105] = '石灵';
    spriteAllMap[2000108] = '风雪虎';
    spriteAllMap[2000111] = '萝莉';
    spriteAllMap[2000114] = '雷童子';
    spriteAllMap[2000120] = '御三家冰狼';
    spriteAllMap[2000124] = '六耳猕猴';
    spriteAllMap[2000149] = '喵大力';
    spriteAllMap[2000157] = '猪刚鬣';
    spriteAllMap[2000163] = '金大锤';
    spriteAllMap[2000166] = '金大球';
    spriteAllMap[2000169] = '莫邪';
    spriteAllMap[2000172] = '人参';
    spriteAllMap[2000175] = '水螃蟹';
    spriteAllMap[2000178] = '木头人';
    spriteAllMap[2000181] = '火老鼠';
    spriteAllMap[2000184] = '兵马俑';
    spriteAllMap[2000187] = '穿山甲';
    spriteAllMap[2000190] = '黑熊';
    spriteAllMap[2000193] = '麻将';
    spriteAllMap[2000196] = '骰子';
    spriteAllMap[2000199] = '安康';
    spriteAllMap[2000202] = '半截观音';
    spriteAllMap[2000205] = '丹炉';
    spriteAllMap[2000208] = '火锅';
    spriteAllMap[2000211] = '独角仙';
    spriteAllMap[2000217] = '花蝴蝶';
    spriteAllMap[2000220] = '少林铜人';
    spriteAllMap[2000223] = '花无缺';
    spriteAllMap[2000234] = '三只狼';
    spriteAllMap[2000237] = '龙椅';
    spriteAllMap[2000239] = '琴女';
    spriteAllMap[2000240] = '大琴女';
    spriteAllMap[2000243] = '猫头鹰';
    spriteAllMap[2000250] = '红玉';
    spriteAllMap[2000252] = '黄九狼';
    spriteAllMap[2000255] = '酒狐';
    spriteAllMap[2000258] = '娇娜';
    spriteAllMap[2000261] = '婴宁';
    spriteAllMap[2000264] = '';
  }
}
