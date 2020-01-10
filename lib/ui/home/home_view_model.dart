import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/page/help.dart';
import 'package:gwgo_helper/page/juanzhu.dart';
import 'package:gwgo_helper/provider/view_state_model.dart';
import 'package:gwgo_helper/ui/promise/promise.dart';
import 'package:gwgo_helper/ui/scanning/scanning_yaoling/scanning_yaoling/scanning_yaoling_page.dart';

/// 首页的ViewModel
/// 1，获取授权
class HomeViewModel extends ViewStateModel {
  HomeViewModel(BuildContext context) {
    this.context = context;
  }

  init() async {
    if(isFirstStart){

    }
  }

  ///
  /// 飞行
  void fly() async {
    if (await _isAuth()) {
      /// 开启飞行
      Navigator.pushNamed(context, '/plainSetting');
    }
  }

  void openPromisePage() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      // return PromisePage();
      return JuanzhuPage();
    }));
  }

  /// 扫描妖灵
  void scanningYaoling() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return ScanningYaolingPage();
    }));
  }

  /// 是否授权
  Future<bool> _isAuth() async {
    if (await PromiseInstance(context).isPromise(context)) {
      return true;
    } else {
      openPromisePage();
      return false;
    }
  }

  onIndicator(){
    Navigator.push(context, CupertinoPageRoute(builder: (context){
      return HelpPage();
    }));
  }


}
