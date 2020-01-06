import 'package:flutter/material.dart';
import 'package:gwgo_helper/provider/view_state_model.dart';
import 'package:toast/toast.dart';

class ScanningSettingsViewModel extends ViewStateModel {
  var modelValue = 0; // 0 经纬度模式 2 瞬移模式 3 导航模式

  var locationModelValue = 0; // 0 wgs座标  1 gcj座标

  ScanningSettingsViewModel(BuildContext context) {
    this.context = context;
  }

  Future init() async {
    // todo 从缓存中读取配置信息
    
  }

  void onModelChanged(int model) {
    // 导航模式还在开发中
    if (model == 2) {
      Toast.show('开发中...', context);
      return;
    }
    modelValue = model;
    notifyListeners();
  }

  void onLocationModelChanged(int model) {
    locationModelValue = model;
    notifyListeners();
  }
}
