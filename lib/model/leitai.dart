/// 擂台数据结构
class Leitai {
  /**
   * "bossfightpower": 13641,
		"bossid": 2000058,
		"bosslevel": 30,
		"freshtime": 1558055998,
		"latitude": 39841310,
		"longtitude": 116287290,
		"starlevel": 4,
		"state": 2
   */
  int state;
  int starlevel;
  int latitude;
  int longtitude;
  int freshtime;
  int bosslevel;
  int bossid;
  int bossfightpower;
  List<Sprite> sprite_list;
  String winner_name;
  int winner_fightpower;

  Leitai(
      {this.state,
      this.starlevel,
      this.latitude,
      this.longtitude,
      this.freshtime,
      this.bosslevel,
      this.bossid,
      this.bossfightpower,
      this.sprite_list,
      this.winner_name,
      this.winner_fightpower});

  factory Leitai.fromJson(Map<String, dynamic> json) {
    int state = json['state'];
    if (state == 2) {
      // group 御灵团战
      return Leitai(
        state: state,
        starlevel: json['starlevel'],
        latitude: json['latitude'],
        longtitude: json['longtitude'],
        freshtime: json['freshtime'],
        bosslevel: json['bosslevel'],
        bossid: json['bossid'],
        bossfightpower: json['bossfightpower'],
      );
    } else if (state == 0) {
      // platform 擂台
      List<dynamic> temp = json['sprite_list'];
      List<Sprite> spriteList = List();
      temp.forEach((item) {
        spriteList.add(Sprite.fromJson(item));
      });
      return Leitai(
        state: json['state'],
        latitude: json['latitude'],
        longtitude: json['longtitude'],
        winner_name: json['winner_name'],
        winner_fightpower: json['winner_fightpower'],
        sprite_list: spriteList,
      );
    } else if (state == 1) {
      // egg 蛋
      return Leitai(
        state: state,
        starlevel: json['starlevel'],
        latitude: json['latitude'],
        longtitude: json['longtitude'],
        freshtime: json['freshtime'],
      );
    }
    return Leitai();
  }

  bool isGroup() {
    return state == 2;
  }

  bool isEgg() {
    return state == 1;
  }

  bool isNormal() {
    return state == 0;
  }

  int getYaolingPower(){
    return sprite_list[0].fightpower + sprite_list[1].fightpower + sprite_list[2].fightpower;
  }
}

class Sprite {
  int level;
  int fightpower;
  int spriteid;
  String name;

  Sprite({this.level, this.fightpower, this.spriteid});

  factory Sprite.fromJson(Map<String, dynamic> json) {
    return Sprite(
      level: json['level'],
      fightpower: json['fightpower'],
      spriteid: json['spriteid'],
    );
  }
}
