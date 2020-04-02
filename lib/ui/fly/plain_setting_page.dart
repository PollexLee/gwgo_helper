import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/utils/common_utils.dart';

/// 飞机设置页面
class PlainSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PlainSettingState();
  }
}

class PlainSettingState extends State<PlainSettingPage> {
  TextEditingController _controller = TextEditingController();

  // var isStart = false;

  Text getButtonText() {
    if (isFly) {
      return Text('御剑飞行停止');
    } else {
      return Text('御剑飞行开始');
    }
  }

  Text getRockerText() {
    if (isShowRocker) {
      return Text('关闭摇杆');
    } else {
      return Text('开启摇杆');
    }
  }

  @override
  void initState() {
    _controller.text = lastLocationString;
    super.initState();
  }

  Widget getStatusIcon() {
    if (isFly) {
      // return Icon(Icons.visibility, size: 100, color: Colors.blue);
      return Text(
        '正在御剑飞行',
        style: TextStyle(fontSize: 40, color: Colors.blue),
      );
    } else {
      return Text(
        '剑已归鞘',
        style: TextStyle(fontSize: 40, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('御剑飞行'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 30),
                child: getStatusIcon(),
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '经纬度',
                    hintText: '39.882606,116.410789(天坛公园)',
                    helperText: '经纬度以英文逗号隔开，先维度后精度\n范例：39.882606,116.410789',
                  ),
                  controller: _controller,
                  enabled: !isFly,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: RaisedButton(
                  child: Text('选择飞行位置'),
                  onPressed: () async {
                    startSelectLocation((String json) {
                      var location = JsonCodec().decode(json);
                      double lat = location['latitude'];
                      double lon = location['longitude'];

                    // 转换成wgs座标
                      var locationArray = gcj02towgs84(lon, lat);
                      lat = locationArray[1];
                      lon = locationArray[0];

                      print('我草，取到参数了，下面只剩解析了: lat = $lat, lon = $lon');
                      _controller.text =
                          '${lat.toStringAsFixed(6)},${lon.toStringAsFixed(6)}';
                      if (!isFly) {
                        toast('选择完成，请点击起飞按钮');
                      } else {
                        fly(lat, lon, false);
                      }
                    });
                    // launch('https://lbs.qq.com/tool/getpoint/index.html');
                  },
                ),
              ),
              // Container(
              //   padding: EdgeInsets.only(top: 10),
              //   child: RaisedButton(
              //     child: Text('粘贴'),
              //     onPressed: () async {
              //       if (isFly) {
              //         toast('请先降落');
              //       }
              //       ClipboardData data = await Clipboard.getData('text/plain');
              //       _controller.text = data.text;
              //     },
              //   ),
              // ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: RaisedButton(
                  child: getButtonText(),
                  onPressed: () async {
                    if (isFly) {
                      // 关闭飞行器
                      isFly = false;
                      isShowRocker = false;
                      saveRockerStatus();
                      setFloatVisiable(false);
                      saveFlyStatus();
                      openAir(0, 0, false);
                    } else {
                      // 打开飞行器
                      String content = _controller.text;
                      var data = content.split(',');
                      if (data.isEmpty || data.length != 2) {
                        toast('经纬度数据异常，请仔细填写(英文逗号)');
                        return;
                      }
                      setLocation(content);

                      dynamic result = await openAir(
                          double.parse(data[0]), double.parse(data[1]), true);
                      if (result == 'success') {
                        setFloatVisiable(true);
                        isFly = true;
                        saveFlyStatus();
                        // Navigator.pop(context);
                      }
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
