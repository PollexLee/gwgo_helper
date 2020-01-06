import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class DialogUtils {
  static ProgressDialog _progressDialog;

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
                  '马上激活',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.popAndPushNamed(context, '/juanzhu');
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

  static showPremissionDialog(BuildContext context, listener) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('请允许指示器获取位置权限和获取手机信息权限'),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  '知道了',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (null != listener) {
                    listener();
                  }
                },
              )
            ],
          );
        });
  }

  static showNoticeDialog(BuildContext context, String content) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text(content),
            actions: <Widget>[
              RaisedButton(
                color: Colors.blueAccent,
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

  /// 显示loading
  static showProgressDialog(BuildContext context, String message) {
    _progressDialog = ProgressDialog(context, ProgressDialogType.Normal);
    _progressDialog.setMessage(message);
    _progressDialog.show();
  }

  /// 更新loading文案
  static updateProgressDialog(BuildContext context, String message) {
    if (_progressDialog == null) {
      showProgressDialog(context, message);
    } else {
      _progressDialog.setMessage(message);
    }
  }

  /// 隐藏loading
  static hideProgressDialog() {
    if (null != _progressDialog && _progressDialog.isShowing()) {
      _progressDialog.hide();
    }
  }

  static showUpdateDialog(
      BuildContext context, String version, String msg, bool isForce) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return Future.value(false);
            },
            child: AlertDialog(
              title: Text('$version版本更新'),
              content: Text('更新内容：\n$msg'),
              actions: <Widget>[
                RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    '去下载',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    launch('https://www.pgyer.com/gwgo');
                  },
                )
              ],
            ),
          );
        });
  }

  /// 展示通知
  static showNotificationDialog(BuildContext context, String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return Future.value(false);
            },
            child: AlertDialog(
              title: Text('通知'),
              content: Text('$msg'),
              actions: <Widget>[
                RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    '知道了',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }
}

bool _isShowProgressDialog = false;

Future showProgressDialog(BuildContext context,
    {bool barrierDismissible = true, String msg}) {
      if(_isShowProgressDialog){
        return null;
      }
  _isShowProgressDialog = true;
  Future f = showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: Colors.black87,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 20,
              ),
              Text(
                msg ?? '加载中...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    },
    barrierDismissible: barrierDismissible,
  );

  f.then((data) {
    _isShowProgressDialog = false;
  });
  return f;
}

dismissProgressDialog(BuildContext context) {
  if (_isShowProgressDialog) {
    Navigator.pop(context);
  }
}