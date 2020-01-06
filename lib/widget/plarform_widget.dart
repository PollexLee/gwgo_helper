import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gwgo_helper/manager/yaoling_info.dart';
import 'package:gwgo_helper/model/leitai.dart';
import 'package:gwgo_helper/sprite_ids.dart';

class PlatformWidget extends StatelessWidget {
  Leitai _leitai;
  Function onTap;
  PlatformWidget(Leitai leitai, {this.onTap}) {
    this._leitai = leitai;
  }

  // @override
  // State<StatefulWidget> createState() {
  //   return PlatformState(_leitai);
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Container(
          alignment: Alignment.topLeft,
          child: ListTile(
            title: Text(
                '擂主：${_leitai.winner_name} 战力:${_leitai.winner_fightpower}'),
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
                              _getYaolingPic(_leitai.sprite_list[0].spriteid)),
                        ),
                        RichText(
                          text: TextSpan(
                              text:
                                  '  ${_getYaolingName(_leitai.sprite_list[0].spriteid)}  等级:${_leitai.sprite_list[0].level}  战力:${_leitai.sprite_list[0].fightpower}',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15)),
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.network(
                              _getYaolingPic(_leitai.sprite_list[1].spriteid)),
                        ),
                        Text(
                          '  ${_getYaolingName(_leitai.sprite_list[1].spriteid)}  等级:${_leitai.sprite_list[1].level}  战力:${_leitai.sprite_list[1].fightpower}',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.network(
                              _getYaolingPic(_leitai.sprite_list[2].spriteid)),
                        ),
                        Text(
                          '  ${_getYaolingName(_leitai.sprite_list[2].spriteid)}  等级:${_leitai.sprite_list[2].level}  战力:${_leitai.sprite_list[2].fightpower}',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('妖灵总战力：${_leitai.getYaolingPower()}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getYaolingPic(int id) {
    // 亮彩香玉
    if (id == 2200267) {
      return 'https://hy.gwgo.qq.com/sync/pet/small/200267.png';
    }
    if (id > 2200000) {
      // 是亮彩
      id = id - 200000;
    }

    if (YaolingInfoManager.yaolingMap[id] == null) {
      print('这个id没有数据：$id');
      // 2200433
      return '';
    } else {
      return YaolingInfoManager.yaolingMap[id].SmallImgPath;
    }
  }

  String _getYaolingName(int id) {
    if (id == 2200267) {
      return '亮彩香奴儿';
    }
    var nameSb = "";

    // 是亮彩
    if (id > 2200000) {
      id = id - 200000;
      nameSb += "亮彩";
    }

    if (YaolingInfoManager.yaolingMap[id] == null) {
      return "未知";
    }
    return nameSb + YaolingInfoManager.yaolingMap[id].Name;
  }
}
