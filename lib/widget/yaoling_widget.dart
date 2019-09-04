import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gwgo_helper/manager/yaoling_info.dart';
import 'package:gwgo_helper/model/yaoling.dart' as prefix0;

import '../yaoling.dart';

class YaolingWidget extends StatefulWidget {
  Yaoling yaoling;
  Function onTap;

  YaolingWidget(Yaoling yaoling, {this.onTap}) {
    this.yaoling = yaoling;
  }

  @override
  State<StatefulWidget> createState() {
    return YaolingState();
  }
}

class YaolingState extends State<YaolingWidget> {
  Timer _countdownTimer;

  @override
  void initState() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    prefix0.Yaoling yaolingInfo = YaolingInfoManager.yaolingMap[widget.yaoling.sprite_id];
    if(null == yaolingInfo){
          return ActionChip(
      elevation: 3.0,
      backgroundColor: _buildYaolingBackgroundColor(widget.yaoling),
      avatar: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text('无'),
      ),
      label: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 50,
            alignment: Alignment.topLeft,
            child: Text(widget.yaoling.name,
              style: TextStyle(fontSize: 10),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            width: 50,
            child: _buildTime(widget.yaoling.dismisstime),
          ),
        ],
      ),
      onPressed: () {
        setState(() {
          widget.yaoling.isClick = true;
        });
        widget.onTap();
      },
    );
    }

    return ActionChip(
      elevation: 3.0,
      backgroundColor: _buildYaolingBackgroundColor(widget.yaoling),
      avatar: CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.network(
          '${yaolingInfo.SmallImgPath}',
          fit: BoxFit.contain,
        ),
      ),
      label: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 50,
            alignment: Alignment.topLeft,
            child: Text(yaolingInfo.Name,
              style: TextStyle(fontSize: 10),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            width: 50,
            child: _buildTime(widget.yaoling.dismisstime),
          ),
        ],
      ),
      onPressed: () {
        setState(() {
          widget.yaoling.isClick = true;
        });
        widget.onTap();
      },
    );
  }           

  Text _buildTime(int time) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
        time - DateTime.now().millisecondsSinceEpoch);
    if (time < DateTime.now().millisecondsSinceEpoch) {
      if (null != _countdownTimer && _countdownTimer.isActive) {
        _countdownTimer.cancel();
        _countdownTimer = null;
      }
      return Text(
        '已过期',
        style: TextStyle(fontSize: 11, color: Colors.red),
      );
    } else {
      return Text(
        '${date.minute}分${date.second}秒',
        style: TextStyle(fontSize: 11, color: Colors.blue),
      );
    }
  }

  Color _buildYaolingBackgroundColor(Yaoling yaoling) {
    if (yaoling.isClick) {
      return Colors.black12;
    } else {
      return yaoling.color;
    }
  }

  Color _buildTextColor(String text) {
    if (text == "已过期") {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  @override
  void dispose() {
    if (_countdownTimer != null) {
      _countdownTimer.cancel();
      _countdownTimer = null;
    }
    super.dispose();
  }
}
