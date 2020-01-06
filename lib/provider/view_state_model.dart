import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'view_state.dart';

class ViewStateModel with ChangeNotifier {
  /// 防止页面销毁后,异步任务才完成,导致报错
  bool _disposed = false;

  /// 当前的页面状态,默认为busy,可在viewModel的构造方法中指定;
  ViewState _viewState;

  BuildContext context;

  /// 根据状态构造
  ///
  /// 子类可以在构造函数指定需要的页面状态
  /// FooModel():super(viewState:ViewState.busy);
  ViewStateModel({ViewState viewState, this.context})
      : _viewState = viewState ?? ViewState.idle;

  ViewState get viewState => _viewState;

  set viewState(ViewState viewState) {
    // _viewStateError = null;
    _viewState = viewState;
    notifyListeners();
  }

  ViewStateError _viewStateError;

  ViewStateError get viewStateError => _viewStateError;

  String get errorMessage => _viewStateError?.message;

  /// 以下变量是为了代码书写方便,加入的get方法.严格意义上讲,并不严谨

  bool get busy => viewState == ViewState.busy;

  bool get idle => viewState == ViewState.idle;

  bool get empty => viewState == ViewState.empty;

  bool get error => viewState == ViewState.error;

  bool get unAuthorized => viewState == ViewState.unAuthorized;

  bool get unPermission => viewState == ViewState.unPermission;

  bool get loginInvalid => viewState == ViewState.loginInvalid;

  void setIdle() {
    viewState = ViewState.idle;
  }

  void setBusy() {
    viewState = ViewState.busy;
  }

  void setEmpty() {
    viewState = ViewState.empty;
  }

  void setUnAuthorized() {
    viewState = ViewState.unAuthorized;
    onUnAuthorizedException();
  }

  void setLoginInvalid() {
    viewState = ViewState.loginInvalid;
    onLoginInvalidException();
  }

  /// 未授权的回调
  void onLoginInvalidException() {}

  /// 未授权的回调
  void onUnAuthorizedException() {
    if (null != context) {
      // Navigator.pushNamedAndRemoveUntil(
      //     context, '/home', (Route<dynamic> route) => false);
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// [e]分类Error和Exception两种
  void setError(e, stackTrace, {String message}) {
    ErrorType errorType = ErrorType.defaultError;
    ViewState _viewState;
    if (e is DioError) {
      e = e.error;
      // if (e is UnPermissionException) {
      //   stackTrace = null;
      //   message = e.message;
      //   errorType = ErrorType.businessError;
      //   _viewState = ViewState.unPermission;
      //   // setUnAuthorized();
      //   // return;
      // } else if (e is LoginInvalidException) {
      //   stackTrace = null;
      //   message = e.message;
      //   errorType = ErrorType.businessError;
      //   _viewState = ViewState.loginInvalid;
      //   // setLoginInvalid();
      //   // return;
      // } else if (e is NotSuccessException) {
      //   stackTrace = null;
      //   message = e.message;
      //   errorType = ErrorType.networkError;
      //   _viewState = ViewState.error;
      // } else {
      errorType = ErrorType.networkError;
      _viewState = ViewState.error;
      // }
    } else {
      errorType = ErrorType.networkError;
      _viewState = ViewState.error;
    }

    _viewStateError = ViewStateError(
      errorType,
      message: message,
      errorMessage: e.toString(),
    );

    viewState = _viewState;
    printErrorStack(e, stackTrace);
  }

  /// 显示错误消息
  showErrorMessage(context, {String message}) {
    if (viewStateError != null && message != null) {
      if (viewStateError.isNetworkError) {
        message ??= 'S.of(context).viewStateMessageNetworkError';
      } else {
        message ??= viewStateError.message;
      }
      Future.microtask(() {
        Toast.show(message, context);
      });
    }
  }

  @override
  String toString() {
    return 'BaseModel{_viewState: $viewState, _viewStateError: $_viewStateError}';
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// [e]为错误类型 :可能为 Error , Exception ,String
/// [s]为堆栈信息
printErrorStack(e, s) {
  debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----error-----↓↓↓↓↓↓↓↓↓↓----->
$e
<-----↑↑↑↑↑↑↑↑↑↑-----error-----↑↑↑↑↑↑↑↑↑↑----->''');
  if (s != null) debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----trace-----↓↓↓↓↓↓↓↓↓↓----->
$s
<-----↑↑↑↑↑↑↑↑↑↑-----trace-----↑↑↑↑↑↑↑↑↑↑----->
    ''');
}
