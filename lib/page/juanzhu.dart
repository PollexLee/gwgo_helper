import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gwgo_helper/manager/PackageInfoManager.dart';
import 'package:gwgo_helper/ui/promise/promise.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class JuanzhuPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return JuanzhuState();
  }
}

class JuanzhuState extends State<JuanzhuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('关于『却邪剑』')),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: <Widget>[
            Text(
                '版本号 ${PackageInfoManager.packageVersion} \n\n令牌价格：20元30天。\n\n付费流程：\n 1.点击复制设备ID；\n2.点击支付宝二维码下载，用支付宝扫码付款，将设备ID粘贴到付款备注中，付款三分钟后，重启指示器即可。\n\n 有问题请联系炼器师QQ或加群。'),
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
              onPressed: () {
                openQQ('3234991420');
              },
              child: Text(
                '联系炼器师QQ',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            RaisedButton(
              onPressed: () {
                openQQGroup();
              },
              child: Text(
                '加入令牌售后群',
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
    launch('https://i.loli.net/2020/01/09/GW7zLd5N6MQkyqB.png');
  }
}
