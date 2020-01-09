import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gwgo_helper/provider/view_state_model.dart';
import 'package:gwgo_helper/ui/promise/promise.dart';
import 'package:gwgo_helper/ui/promise/promise_model.dart';
import 'package:gwgo_helper/utils/dialog_utils.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class PromiseViewModel extends ViewStateModel {
  final tokenMap = {'周令牌': '10', '月令牌': '25', '季令牌': '70', '年令牌': '200'};

  PromiseModel promiseModel;

  var selectTokenType = '月令牌';
  PromiseViewModel(BuildContext context) {
    this.context = context;
  }

  bool isSelect(String type) {
    return selectTokenType == type;
  }

  /// 初始化
  Future init() async {
    promiseModel = PromiseInstance(context).promiseModel;
    notifyListeners();
  }

  void onTokenCheck(String type) {
    selectTokenType = type;
    notifyListeners();
  }

  /// 确认购买按钮
  void onByClick() {
    Toast.show('开发中...', context);
    return;
    showProgressDialog(context);

    /// 请求服务的二维码接口 返回二维码地址和失效时间，
    ///
    promiseModel = PromiseModel(
        qrCodeimageUrl: 'https://i.loli.net/2020/01/01/nmd9uPUQqBWRfsL.png',
        invalidTime: '1577947238000',
        codeName: selectTokenType);

    dismissProgressDialog(context);
    notifyListeners();
    PromiseInstance(context).promiseModel = promiseModel;
  }

  /// 保存二维码图片
  void saveQrCodeImage() {
    Toast.show('请手动保存图片', context);
    Timer(Duration(seconds: 1), () {
      launch(promiseModel.qrCodeimageUrl);
    });
  }
}
