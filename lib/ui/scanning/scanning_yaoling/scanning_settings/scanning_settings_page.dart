import 'package:flutter/material.dart';
import 'package:gwgo_helper/provider/provider_widget.dart';
import 'package:gwgo_helper/ui/scanning/scanning_yaoling/scanning_settings/scanning_settings_view_model.dart';

class ScanningSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScanningSettingsState();
  }
}

class ScanningSettingsState extends State<ScanningSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ScanningSettingsViewModel>(
      viewModel: ScanningSettingsViewModel(context),
      onReady: (model) async {
        await model.init();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('妖灵探测设置'),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '寻路模式',
                            style: Theme.of(context).textTheme.title,
                          ),
                          RadioListTile(
                            value: 0,
                            groupValue: model.modelValue,
                            onChanged: model.onModelChanged,
                            title: Text(
                              '经纬度模式',
                              style: TextStyle(),
                            ),
                            subtitle: Text('点击扫描到的妖灵，会复制妖灵的经纬度到粘贴板'),
                          ),
                          RadioListTile(
                            value: 1,
                            groupValue: model.modelValue,
                            onChanged: model.onModelChanged,
                            title: Text('瞬移模式'),
                            subtitle: Text('开启御剑飞行功能时，点击扫描到的妖灵，会瞬移到妖灵所在位置'),
                          ),
                          RadioListTile(
                            value: 2,
                            groupValue: model.modelValue,
                            onChanged: model.onModelChanged,
                            title: Text('导航模式'),
                            subtitle:
                                Text('开启御剑飞行功能时，点击扫描到的妖灵，会根据地图导航，沿着路线跑到妖灵所在位置'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  crossFadeState: model.modelValue == 0
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                  firstChild: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                            '坐标系',
                            style: Theme.of(context).textTheme.title,
                          ),
                            RadioListTile(
                            value: 0,
                            groupValue: model.locationModelValue,
                            onChanged: model.onLocationModelChanged,
                            title: Text('wgs84坐标系'),
                            subtitle: Text('火星坐标系，适用于GPS JoyStick、Fake Location、iOS外设 等'),
                          ),
                          RadioListTile(
                            value: 1,
                            groupValue: model.locationModelValue,
                            onChanged: model.onLocationModelChanged,
                            title: Text('gcj02坐标系'),
                            subtitle: Text('国测局坐标系，适用于幻影 等'),
                          ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  secondChild: Container(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
