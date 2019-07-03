import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gwgo_helper/utils/common_utils.dart';

class DialogUtils {
  static showExitDialog(BuildContext context) {}

  static showRegistDialog(BuildContext context, String deviceId, isRegiste) {
    String content;
    if (isRegiste) {
      content = '设备ID：$deviceId \n\n此设备注册已过期，请复制设备ID后联系\nQQ：3234991420\n进行续费。';
    } else {
      content = '设备ID：$deviceId \n\n此设备未注册，请复制以上信息后联系\nQQ：3234991420\n进行注册。';
    }
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text(content),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  '复制设备ID',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: deviceId));
                  toast(
                    '已复制设备ID',
                  );
                },
              ),
              RaisedButton(
                child: Text(
                  '复制QQ号',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '3234991420'));
                  toast('已复制QQ号码');
                },
              ),
              RaisedButton(
                child: Text(
                  '知道了',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  static showNetworkErrorDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('网络异常，请联网后再启动飞行指示器'),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  '知道了',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  static showPremissionDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('请授予指示器获取位置权限和获取手机信息权限'),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  '知道了',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
