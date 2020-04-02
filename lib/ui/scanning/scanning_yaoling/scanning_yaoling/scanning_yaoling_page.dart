import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/provider/provider_widget.dart';
import 'package:gwgo_helper/sprite_ids.dart';
import 'package:gwgo_helper/ui/scanning/scanning_yaoling/scanning_settings/scanning_settings_page.dart';
import 'package:gwgo_helper/ui/scanning/scanning_yaoling/scanning_yaoling/scanning_yaoling_view_model.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:gwgo_helper/widget/yaoling_widget.dart';
import 'package:gwgo_helper/yaoling.dart';

class ScanningYaolingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScanningYaolingState();
  }
}

class ScanningYaolingState extends State<ScanningYaolingPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return ProviderWidget<ScanningYaolingViewModel>(
      viewModel: ScanningYaolingViewModel(context),
      onReady: (model) async {
        await model.init();
      },
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            model.closeScanning();
            return true;
          },
          child: Scaffold(
            key: model.key,
            appBar: AppBar(
              title: Text(
                model.allData.isEmpty
                    ? '妖灵探测'
                    : '妖灵探测 - 共${model.allData.length}只',
                style: TextStyle(fontSize: 14),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.adb),
                  onPressed: () {
                    model.openSetting();
                  },
                  tooltip: '选择妖灵',
                ),
                IconButton(
                  icon: Icon(Icons.map,
                      color: startList[1].latitude == -1
                          ? Colors.red
                          : Colors.white),
                  onPressed: () {
                    model.openSelectPosition();
                  },
                  tooltip: '选择区域',
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  tooltip: '设置',
                  onPressed: () {
                    // 修改
                    Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return ScanningSettingsPage();
                    }));
                  },
                ),
              ],
            ),
            body: !model.scanning
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: model.delayTime == 10
                              ? () {
                                  model.scanningYaoling();
                                }
                              : null,
                          child: Text('释放剑气，开始探测 ${model.getDelayTime()}'),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        RaisedButton(
                          onPressed: (){
                            openQQ('3234991420');
                          },
                          child: Text('联系炼器师补足剑气'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 5),
                        Container(
                          alignment: Alignment.center,
                          child: Text(model.processString),
                          // '  耗时：${widget.time.toString()}秒'),
                        ),
                        RaisedButton(
                          child: Text('重新扫描'),
                          onPressed: () {
                            model.scanningYaoling();
                          },
                        ),
                        _buildYaoling(model),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// 构建妖灵列表
  Widget _buildYaoling(ScanningYaolingViewModel model) {
    List<Widget> widgetList = List();
    // 遍历妖灵数据
    if (null != model.allData && model.allData.isNotEmpty) {
      var iterator = model.allData.iterator;
      while (iterator.moveNext()) {
        var yaoling = iterator.current;
// 在选中的妖灵中
        if (SpriteConfig.selectedMap.contains(yaoling.sprite_id)) {
          // 大于等于200，提示
          if (widgetList.length >= 200) {
            model.key.currentState.showSnackBar(SnackBar(
              content: Text('妖灵数量已大于200，不再添加'),
            ));
            break;
          } else {
            // 小于200，添加到UI中
            widgetList.add(YaolingWidget(
              yaoling,
              onTap: () {
                clickYaolingData.add(yaoling);
                teleport(yaoling.latitude / 1e6, yaoling.longtitude / 1e6);
              },
            ));
          }
        }
      }
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.start,
      children: widgetList,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
