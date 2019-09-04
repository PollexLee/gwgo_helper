import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../promise.dart';

class JuanzhuPage extends StatefulWidget {
  var version;

  @override
  State<StatefulWidget> createState() {
    return JuanzhuState();
  }
}

class JuanzhuState extends State<JuanzhuPage> {
  @override
  void initState() {
    Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
    packageInfo.then((info) {
      setState(() {
        widget.version = info.version;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('关于飞行指示器')),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: <Widget>[
            Text(
                '版本号 ${widget.version} \n\n价格：15元30天。\n\n付费流程：\n 1.复制设备ID；\n2.点击二维码下载，用支付宝或微信付款，将设备ID粘贴到付款备注中，付款三分钟后，重启指示器即可。\n\n 有问题请咨询开发QQ群：162411670'),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: RaisedButton(
                onPressed: () {
                  if (PromiseInstance(context).imeiList == null ||
                      PromiseInstance(context).imeiList.isEmpty) {
                    toast('没有获取到设备ID，请授权后重启指示器');
                    return;
                  }
                  Clipboard.setData(ClipboardData(
                      text: PromiseInstance(context).imeiList[0]));
                  toast(
                    '已复制设备ID',
                  );
                },
                child: Text(
                  '复制设备ID',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            RaisedButton(
              onPressed: openAliPayQR,
              child: Text(
                '支付宝二维码下载',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            RaisedButton(
              onPressed: openWeChatQR,
              child: Text(
                '微信二维码下载',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ],
        ),
      ),
    );
  }

  void openWeChatQR() {
    launch('https://i.loli.net/2019/08/19/savTWZCy9mljeAd.png');
  }

  void openAliPayQR() {
    launch('https://i.loli.net/2019/08/19/YZWCtfVeDz7qsad.jpg');
  }
}
