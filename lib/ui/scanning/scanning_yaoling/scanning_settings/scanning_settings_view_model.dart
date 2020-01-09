import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/provider/view_state_model.dart';
import 'package:toast/toast.dart';

class ScanningSettingsViewModel extends ViewStateModel {
  var modelValue = 0; // 0 经纬度模式 1 瞬移模式 2 导航模式

  var locationModelValue = 0; // 0 wgs座标  1 gcj座标

  var startGame = 0; // 0 启动  1 不启动

  ScanningSettingsViewModel(BuildContext context) {
    this.context = context;
  }

  Future init() async {
    // todo 从缓存中读取配置信息
    modelValue = flyModel;
    locationModelValue = locationType;
    startGame = isStartAir ? 0 : 1;
  }

  void onModelChanged(int model) {
    // 导航模式还在开发中
    if (model == 2) {
      Toast.show('开发中...', context);
      return;
    } else if (model == 0) {
      setOpenFly(false);
      // setStartAir(false);
    } else if (model == 1) {
      // 瞬移
      setOpenFly(true);
      // setStartAir(true);
    }
    setFlyModel(model);
    modelValue = model;
    notifyListeners();
  }

  void onLocationModelChanged(int model) {
    setLocationType(model);
    locationModelValue = model;
    notifyListeners();
  }

  void onStartGameChanged(int value) {
    if (value == 0) {
      setStartAir(true);
    } else if (value == 1) {
      setStartAir(false);
    }
    startGame = value;
    notifyListeners();
  }
}
