import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';

class Yaoling {
  int gentime;
  int latitude;
  int lifetime;
  int longtitude;
  int sprite_id;
  String name;
  int dismisstime;
  bool isClick = false;
  Color color;
  String SmallImgPath;
  String BigImgPath;
  String unitId;

  Yaoling(
      {this.gentime,
      this.lifetime,
      this.latitude,
      this.longtitude,
      this.sprite_id,
      this.name,
      this.SmallImgPath,
      this.BigImgPath}) {
    this.dismisstime = (gentime + lifetime) * 1000;
  }

  int getDismissTime() {
    return dismisstime - DateTime.now().millisecondsSinceEpoch;
  }

  String getUnitId() {
    if (unitId == null) {
      var content = utf8.encode('$latitude$longtitude$sprite_id');
      unitId = md5.convert(content).toString();
    }
    return unitId;
  }

  factory Yaoling.fromjson(Map<String, dynamic> json) {
    return Yaoling(
      gentime: json['gentime'],
      lifetime: json['lifetime'],
      latitude: json['latitude'],
      longtitude: json['longtitude'],
      sprite_id: json['sprite_id'],
      SmallImgPath: json['SmallImgPath'],
      BigImgPath: json['BigImgPath'],
    );
  }

  @override
  bool operator ==(other) => getUnitId() == other.getUnitId();
}
