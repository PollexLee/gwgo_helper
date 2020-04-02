import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/core/websocket_callback.dart';
import 'package:gwgo_helper/manager/token_manager.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:toast/toast.dart';

/// 用来建立WebSocket连接的地址
String URL =
    // wss://publicld.gwgo.qq.com/?account_value=0&account_type=0&appid=0&token=0
    "wss://publicld.gwgo.qq.com?account_value=0&account_type=0&appid=0&token=0";

class WebSocketCore {
  /// socket集合
  List<GwgoSocketWrap> socketStack = List();

  /// 请求集合
  List<Request> requestStack = List();

  Function initSuccess;

  bool isNotify = false;

  init(int count, Function initSuccess) async {
    this.initSuccess = initSuccess;
    socketStack.clear();
    // 循环添加五个socket
    for (var i = 0; i < count; i++) {
      socketStack.add(await createWebSocket());
    }
  }

  /// 提供给外部调用的发送数据结构
  Future send(int requestId, String content, Callback callback) async {
    var request = Request(requestId, content, callback);
    requestStack.add(request);
    next();
  }

  /// 实际发送数据的地方
  void _sendData(GwgoSocketWrap socket, Request request) {
    print('发起请求 id= ${request.id}');
    Uint8List result = Uint8List(4 + request.content.length);
    Uint8List head = Uint8List(4);
    ByteData.view(head.buffer).setUint32(0, request.content.length);
    result.setAll(0, head);
    result.setAll(4, request.content.codeUnits);
    request.realContent = result;
    socket.send(request, (bool valid) {
      if (valid) {
        next();
      } else {
        requestStack.clear();
      }
    });
  }

  /// 执行下一个请求
  Future next() async {
    // 请求队列中有数据，发送请求
    if (null != requestStack && requestStack.isNotEmpty) {
      for (var socket in socketStack) {
        if (socket.status == GwgoSocketWrap.ready) {
          _sendData(socket, requestStack.first);
          requestStack.remove(requestStack.first);
          print('还有${requestStack.length}条请求');
          await next();
          break;
        }
      }
    }
  }

  void close() async {
    requestStack.clear();
    if (socketStack == null || socketStack.isEmpty) {
      return;
    }
    for (var item in socketStack) {
      item.close();
      item = null;
    }
    socketStack.clear();
  }

  Future<GwgoSocketWrap> createWebSocket() async {
    var socket = GwgoSocketWrap();
    socket.create(() {
      bool allReady = true;
      for (var item in socketStack) {
        if (item.status != GwgoSocketWrap.ready) {
          allReady = false;
        }
        if (allReady && !isNotify) {
          isNotify = true;
          initSuccess(0);
        }
      }
    });
    return socket;
  }
}

/// 请求的数据结构
class Request {
  int id;
  String content;
  Callback callback;
  Uint8List realContent;

  Request(this.id, this.content, this.callback);
}

class GwgoSocketWrap {
  Request _request;
  Function _gwgoCallback;
  Function _connected;
  WebSocket _socket;
  Timer _timer;
  bool valid = true;

  int count;

  int status = connecting;

  static const int ready = 1; // 等待发送数据
  static const int waitting = 2; // 等待返回数据
  static const int connecting = 3; // 正在连接
  bool _isClose = false;

  Future create(Function connected) async {
    count = 1;
    _connected = connected;
    try {
      _socket = await WebSocket.connect(URL);
      _socket.listen(
        dataHandler,
        onError: errorHandler,
        onDone: doneHandler,
        cancelOnError: false,
      );
    } catch (exception) {
      if (!_isClose) {
        print('异常了，稍后新创建');
        Timer(Duration(seconds: 1), () {
          create(connected);
        });
      }
    }
  }

  close() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = null;
    _isClose = true;
    if (null != _socket && _socket.readyState == WebSocket.open) {
      _socket.close();
    }
    _socket = null;
    _gwgoCallback = null;
    _request = null;
  }

  send(Request request, Function gwgoCallback) {
    if (_request == null) {
      count = 1;
      status = waitting;
      _request = request;
      _gwgoCallback = gwgoCallback;
      _handleRequest();
    } else {
      print('当前Socket已经有任务了');
    }
  }

  bool hasRequest() {
    return _request != null;
  }

  /// 处理请求
  _handleRequest() {
    if (_request == null) {
      print('没有任务了。');
    } else {
      _loopWriteData(_request.realContent);
    }
  }

  _loopWriteData(data) {
    // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   if (_isClose) {
    //     try{
    //       _timer.cancel();
    //     }catch(e){
    //       print(e.toString());
    //     }
    //     _timer = null;
    //     return;
    //   }
    //   if (_request == null) {
    //     _timer.cancel();
    //     _timer = null;
    //   }
    //   count++;
    //   print('循环请求: $count次');
    //   if (count >= 3) {
    //     dataHandler(null);
    //     return;
    //   }
    if (getSocket() != null && getSocket().readyState == WebSocket.open) {
      getSocket().add(data);
    } else {
      if (getSocket() == null) {
        print('socket异常了,socket = null');
        doneHandler();
      } else {
        print('socket异常了,socket = ${getSocket().readyState}');
      }
    }
    // });
  }

  /// 连接错误
  void errorHandler(error) async {
    print('socket错误了');
    status = connecting;
    await create(() {});
  }

  WebSocket getSocket() {
    return _socket;
  }

  /// 连接断开
  void doneHandler() async {
    count = 1;
    if (_isClose) {
      print('手动终止socket');
      return;
    }
    print('socket结束了, 重新创建一个');
    status = connecting;
    await create(() {});
  }

  // 收到数据
  // todo  处理接口返回 断开的情况
  Future<void> dataHandler(data) async {
    if (null == data) {
      // 接口超时时，data是null，触发空回调
      await _request.callback.onReceiveData(null);
      return;
    } else {
      if (data.runtimeType == String) {
        if (data.toString().contains('pass')) {
          status = ready;
          print('socket连接成功');
          _connected();
          if (_request != null) {
            status = waitting;
          }
        } else if (data.toString().contains('"reason":7')) {
          print('服务端终止');
          return;
        } else {
          print('未知的字符串$data');
        }
      } else {
        if (_request == null) {
          return;
        }

        // 调用对应请求的callback
        Uint8List list = data;
        Utf8Decoder decoder = Utf8Decoder(allowMalformed: true);
        String result = '';
        try {
          result = decoder.convert(list.sublist(4));
        } catch (exception) {
          print(exception);
        }

        if (result.contains('retcode":10004') ||
            result.contains('retcode":10003')) {
          // token失效，删除此token
          print('token失效了，删除$token');
          toast('配置失效，请重新获取');
          TokenManager.deleteToken(token);
          valid = false;
          await _request.callback.onReceiveData(null);
          return;
        }

        /// 替换掉不显示的特殊字符
        result = result.replaceAll(String.fromCharCode(0x01), ' ');
        result = result.replaceAll(String.fromCharCode(0x02), ' ');
        result = result.replaceAll(String.fromCharCode(0x03), ' ');
        result = result.replaceAll(String.fromCharCode(0x04), ' ');
        result = result.replaceAll(String.fromCharCode(0x05), ' ');
        result = result.replaceAll(String.fromCharCode(0x06), ' ');
        result = result.replaceAll(String.fromCharCode(0x07), ' ');
        result = result.replaceAll(String.fromCharCode(0x08), ' ');
        result = result.replaceAll(String.fromCharCode(0x09), ' ');
        result = result.replaceAll(String.fromCharCode(0x10), ' ');
        result = result.replaceAll(String.fromCharCode(0x11), ' ');
        result = result.replaceAll(String.fromCharCode(0x12), ' ');
        result = result.replaceAll(String.fromCharCode(0x13), ' ');
        result = result.replaceAll(String.fromCharCode(0x14), ' ');
        result = result.replaceAll(String.fromCharCode(0x0a), ' ');
        result = result.replaceAll(String.fromCharCode(0x0b), ' ');
        result = result.replaceAll(String.fromCharCode(0x0c), ' ');
        result = result.replaceAll(String.fromCharCode(0x0d), ' ');
        result = result.replaceAll(String.fromCharCode(0x0e), ' ');
        result = result.replaceAll(String.fromCharCode(0x0f), ' ');
        result = result.replaceAll(String.fromCharCode(0x7f), ' ');
        print('返回数据：$result');

        JsonCodec jsonCodec = JsonCodec();
        Map<String, dynamic> resultMap = Map();
        try {
          if (result.contains('filename')) {
            // 是文件配置信息，就替换掉空格
            result = result.trim().replaceAll(' ', '"');
          }
          resultMap = jsonCodec.decode(result);
          // }
        } catch (exc) {
          print(exc.toString());
          print(list);
        }
        int id = resultMap['requestid'];
        if (id != _request.id) {
          print('id匹配失败，id = $id, requestId = ${_request.id}');
          return;
        } else {
          print('id匹配成功，id = $id');
        }

        if (_timer != null) {
          _timer.cancel();
        }
        await _request.callback.onReceiveData(resultMap);
      }
    }
    _request = null;
    _timer = null;
    status = ready;
    if (null != _gwgoCallback) {
      Timer(Duration(milliseconds: 300), () {
        _gwgoCallback(valid);
      });
    }
    // 当前request已处理完成
  }
}
