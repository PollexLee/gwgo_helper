import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gwgo_helper/manager/yaoling_info.dart';
import 'package:gwgo_helper/model/leitai.dart';
import 'package:gwgo_helper/sprite_ids.dart';

class PlatformWidget extends StatefulWidget {
  Leitai _leitai;
  Function onTap;
  PlatformWidget(Leitai leitai, {this.onTap}) {
    this._leitai = leitai;
  }

  @override
  State<StatefulWidget> createState() {
    return PlatformState(_leitai);
  }
}

class PlatformState extends State<PlatformWidget> {
  Leitai leitai;

  PlatformState(Leitai leitai) {
    this.leitai = leitai;
  }

  String _getYaolingName(int id) {
    if(id == 2200267){
      return '香奴儿';
    }
    if(YaolingInfoManager.yaolingMap[id] == null){
      return "未知";
    } 
    return YaolingInfoManager.yaolingMap[id].Name;
  }

  String _getYaolingPic(int id) {
    if(id == 2200267){
      return 'https://hy.gwgo.qq.com/sync/pet/small/200267.png';
    }
    if (YaolingInfoManager.yaolingMap[id] == null) {
      print('这个id没有数据：$id');
      return '';
    } else {
      return YaolingInfoManager.yaolingMap[id].SmallImgPath;
    }
  }

  @override
  void initState() {
    SpriteConfig.initAllMap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Container(
          alignment: Alignment.topLeft,
          child: ListTile(
            title:
                Text('擂主：${leitai.winner_name} 战力:${leitai.winner_fightpower}'),
            subtitle: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.network(
                              _getYaolingPic(leitai.sprite_list[0].spriteid)),
                        ),
                        RichText(
                          text: TextSpan(text: '  ${_getYaolingName(leitai.sprite_list[0].spriteid)}  等级:${leitai.sprite_list[0].level}  战力:${leitai.sprite_list[0].fightpower}',
                          style: TextStyle(color: Colors.black, fontSize: 15)),
                          ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.network(
                              _getYaolingPic(leitai.sprite_list[1].spriteid)),
                        ),
                        Text(
                            '  ${_getYaolingName(leitai.sprite_list[1].spriteid)}  等级:${leitai.sprite_list[1].level}  战力:${leitai.sprite_list[1].fightpower}',
                            style: TextStyle(fontSize: 15, color: Colors.black),),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.network(
                              _getYaolingPic(leitai.sprite_list[2].spriteid)),
                        ),
                        Text(
                            '  ${_getYaolingName(leitai.sprite_list[2].spriteid)}  等级:${leitai.sprite_list[2].level}  战力:${leitai.sprite_list[2].fightpower}',
                            style: TextStyle(fontSize: 15, color: Colors.black),),
                      ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
