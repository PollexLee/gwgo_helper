import 'package:flutter/material.dart';
import 'package:gwgo_helper/provider/provider_widget.dart';
import 'package:gwgo_helper/ui/promise/promise.dart';
import 'package:gwgo_helper/ui/promise/promise_view_model.dart';

class PromisePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PromiseState();
  }
}

class PromiseState extends State<PromisePage> {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<PromiseViewModel>(
      viewModel: PromiseViewModel(context),
      onReady: (model) async {
        await model.init();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('操控令牌'),
          ),
          body: _buildBody(model),
        );
      },
    );
  }

  Widget _buildBody(PromiseViewModel model) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        model.promiseModel == null
            ? Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: _buildTokenWidgets(model),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                        child: Text(
                          '请求付款二维码(' +
                              model.tokenMap[model.selectTokenType] +
                              '元)',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          model.onByClick();
                        },
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(height: 10),
        model.promiseModel == null
            ? SizedBox()
            : Column(
                children: <Widget>[
                  Text(
                    '令牌类型：${model.promiseModel.codeName}  \n失效时间：${model.promiseModel.invalidTime}',
                    style: TextStyle(fontSize: 18, color: Colors.indigo),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 400,
                    child: Center(
                      child: Image.network(model.promiseModel.qrCodeimageUrl),
                    ),
                  ),
                  SizedBox(height: 10),
                  FlatButton(
                    child: Text(
                      '保存二维码',
                      style: TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                    onPressed: () {
                      model.saveQrCodeImage();
                    },
                  ),
                ],
              ),
      ],
    ));
  }

  /// 令牌
  List<Widget> _buildTokenWidgets(PromiseViewModel model) {
    List<Widget> result = List();
    model.tokenMap.forEach((key, value) {
      result.add(Container(
        height: 70,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.grey, width: 1),
          color: model.isSelect(key) ? Colors.blue : Colors.white,
        ),
        child: FlatButton(
          splashColor: Colors.blue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
          onPressed: () {
            model.onTokenCheck(key);
          },
          child: Center(
              child: Text(
            key + '($value元)',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: model.isSelect(key) ? Colors.white : Colors.black87),
          )),
        ),
      ));
    });
    return result;
  }
}
