import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

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
                '版本号 ${widget.version} \n\n扫描如下付款图片付款'),
            // Card(
            //   margin: EdgeInsets.only(top: 20),
            //   child: Container(
            //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            //     child: Image.asset(
            //       'image/alipay.png',
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: RaisedButton(
                onPressed: openAliPayQR,
                child: Text(
                  '支付宝二维码下载',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
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
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                '\n捐助名单：',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Text(
                    '螃蟹',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  Text(
                    '前四左三',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void openWeChatQR() {
    launch('https://i.loli.net/2019/05/26/5cea72c27ebc891912.png');
  }

  void openAliPayQR() {
    launch('https://i.loli.net/2019/05/26/5cea72c27fcb988977.png');
  }
}
