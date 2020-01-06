import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/provider/view_state_model.dart';
import 'package:toast/toast.dart';

import 'view_state.dart';

/// 加载中
class ViewStateBusyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

/// 基础Widget
class ViewStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final Widget image;
  final Widget buttonText;
  final String buttonTextData;
  final VoidCallback onPressed;

  ViewStateWidget(
      {Key key,
      this.image,
      this.title,
      this.message,
      this.buttonText,
      @required this.onPressed,
      this.buttonTextData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var titleStyle =
        Theme.of(context).textTheme.subhead.copyWith(color: Colors.grey);
    var messageStyle = titleStyle.copyWith(
        color: titleStyle.color.withOpacity(0.7), fontSize: 14);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        image ?? Icon(Icons.error, size: 80, color: Colors.grey[500]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title ?? '加载失败',
                style: titleStyle,
              ),
              SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200, minHeight: 150),
                child: SingleChildScrollView(
                  child: Text(message ?? '', style: messageStyle),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: ViewStateButton(
            child: buttonText,
            textData: buttonTextData,
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}

class ViewStateErrorWidget extends StatelessWidget {
  final ViewStateError error;
  final String title;
  final String message;
  final Widget image;
  final Widget buttonText;
  final String buttonTextData;
  final VoidCallback onPressed;

  const ViewStateErrorWidget({
    Key key,
    @required this.error,
    this.image,
    this.title,
    this.message,
    this.buttonText,
    this.buttonTextData,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var defaultImage;
    var defaultTitle;
    var errorMessage = error.message;
    String defaultTextData = '重试';
    switch (error.errorType) {
      case ErrorType.networkError:
        defaultImage = Icon(Icons.error, size: 100, color: Colors.grey);
        defaultTitle = '网络连接异常,请检查网络或稍后重试';
        errorMessage = ''; // 网络异常移除message提示
        break;
      case ErrorType.defaultError:
        defaultImage = const Icon(Icons.error, size: 100, color: Colors.grey);
        defaultTitle = '加载失败';
        break;
      case ErrorType.businessError:
        defaultImage = const Icon(Icons.error, size: 100, color: Colors.grey);
        defaultTitle = '';
        break;
    }

    return ViewStateWidget(
      onPressed: this.onPressed,
      image: image ?? defaultImage,
      title: title ?? defaultTitle,
      message: message ?? errorMessage,
      buttonTextData: buttonTextData ?? defaultTextData,
      buttonText: buttonText,
    );
  }
}

/// 页面无数据
class ViewStateEmptyWidget extends StatelessWidget {
  final String message;
  final Widget image;
  final Widget buttonText;
  final VoidCallback onPressed;

  const ViewStateEmptyWidget(
      {Key key,
      this.image,
      this.message,
      this.buttonText,
      @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewStateWidget(
      onPressed: this.onPressed,
      image: image ??
          const Icon(Icons.hourglass_empty, size: 100, color: Colors.grey),
      title: message ?? '空空如也',
      buttonText: buttonText,
      buttonTextData: '刷新一下',
    );
  }
}

/// 页面未授权
class ViewStateUnAuthWidget extends StatelessWidget {
  final String message;
  final Widget image;
  final Widget buttonText;
  final VoidCallback onPressed;

  const ViewStateUnAuthWidget(
      {Key key,
      this.image,
      this.message,
      this.buttonText,
      @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewStateWidget(
      onPressed: this.onPressed,
      image: image ?? ViewStateUnAuthImage(),
      title: message ?? '未登录',
      buttonText: buttonText,
      buttonTextData: '登录',
    );
  }
}

/// 未授权图片
class ViewStateUnAuthImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'loginLogo',
      child: Text('未授权'),
      // child: Image.asset(
      //   ImageHelper.wrapAssets('login_logo.png'),
      //   width: 130,
      //   height: 100,
      //   fit: BoxFit.fitWidth,
      //   color: Theme.of(context).accentColor,
      //   colorBlendMode: BlendMode.srcIn,
      // ),
    );
  }
}

/// 公用Button
class ViewStateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String textData;

  const ViewStateButton({@required this.onPressed, this.child, this.textData})
      : assert(child == null || textData == null);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      child: child ??
          Text(
            textData ?? '重试',
            style: TextStyle(wordSpacing: 5),
          ),
      textColor: Colors.grey,
      splashColor: Theme.of(context).splashColor,
      onPressed: onPressed,
      highlightedBorderColor: Theme.of(context).splashColor,
    );
  }
}

class BodyWidget<T extends ViewStateModel> extends StatefulWidget {
  final T model;
  final WidgetBuilder builder;
  final Function() retry;
  BodyWidget({this.model, this.builder, this.retry});

  @override
  State<StatefulWidget> createState() {
    return BodyState();
  }
}

class BodyState extends State<BodyWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.model.error) {
      return ViewStateErrorWidget(
        onPressed: widget.retry,
        error: widget.model.viewStateError,
      );
    } else if (widget.model.unPermission) {
      return ViewStateErrorWidget(
        onPressed: widget.retry,
        error: widget.model.viewStateError,
      );
    } else if (widget.model.loginInvalid) {
      Toast.show('登录已过期，请重新登录', context);
      Timer(Duration(seconds: 1), () {
        //   Navigator.pushNamedAndRemoveUntil(
        //     context, '/home', (Route<dynamic> route) => false);
        // });
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (Route<dynamic> route) => false);
      });
      return ViewStateErrorWidget(
        onPressed: widget.retry,
        error: widget.model.viewStateError,
      );
    } else {
      return widget.builder(context);
    }
  }
}
