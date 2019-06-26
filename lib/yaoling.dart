import 'dart:ui';

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

  Yaoling(
      {this.gentime,
      this.lifetime,
      this.latitude,
      this.longtitude,
      this.sprite_id,
      this.name}){
      this.dismisstime = (gentime + lifetime) * 1000;
      }

  int getDismissTime() {
    return dismisstime -
        DateTime.now().millisecondsSinceEpoch;
  }

  factory Yaoling.fromjson(Map<String, dynamic> json) {
    return Yaoling(
      gentime: json['gentime'],
      lifetime: json['lifetime'],
      latitude: json['latitude'],
      longtitude: json['longtitude'],
      sprite_id: json['sprite_id'],
    );
  }
}
