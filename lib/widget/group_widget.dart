import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gwgo_helper/model/leitai.dart';

class GroupWidget extends StatefulWidget {
  Leitai _leitai;
  Function onTap;
  GroupWidget(Leitai leitai, {this.onTap}) {
    this._leitai = leitai;
  }

  @override
  State<StatefulWidget> createState() {
    return GroupState(_leitai);
  }
}

class GroupState extends State<GroupWidget> {
  Leitai leitai;
  Timer _countdownTimer;
  int remainingTime;
  String timeStr = '';

  GroupState(Leitai leitai) {
    this.leitai = leitai;
    this.remainingTime =
        (leitai.freshtime * 1000 - DateTime.now().millisecondsSinceEpoch) -
            8 * 60 * 60 * 1000;
  }

  @override
  void initState() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(remainingTime);
    timeStr = '${date.hour}时${date.minute}分${date.second}秒';
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      remainingTime -= 1000;
      if (remainingTime <= -28800000) {
        _countdownTimer.cancel();
        _countdownTimer = null;
        setState(() {
          timeStr = '已过期';
        });
      } else {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(remainingTime);
        setState(() {
          timeStr = '${date.hour}时${date.minute}分${date.second}秒';
        });
      }
    });

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
          child: ListTile(
            title: Text('御灵团战-五星句芒'),
            subtitle: Row(
              children: <Widget>[
                Text('过期时间：'),
                Text(
                  '$timeStr',
                  style: TextStyle(color: _buildTextColor(timeStr)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }
}
