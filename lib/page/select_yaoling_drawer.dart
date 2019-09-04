import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectYaolingDrawerWidget extends StatefulWidget {
  var groupValue;
  ValueChanged<String> onLevelChanged;

  SelectYaolingDrawerWidget(this.groupValue, this.onLevelChanged);

  @override
  State<StatefulWidget> createState() {
    return SelectYaolingDrawerState();
  }
}

class SelectYaolingDrawerState extends State<SelectYaolingDrawerWidget> {
  _onChanged(String value) {
    widget.groupValue = value;
    widget.onLevelChanged(value);
    setState(() {});
    Timer(Duration(milliseconds: 300), () {
      if (Scaffold.of(context).isEndDrawerOpen) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 1000,
      color: Colors.white,
      child: SafeArea(
          child: Column(
        children: <Widget>[
          Text(
            '筛选项',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          RadioListTile<String>(
            value: '1',
            groupValue: widget.groupValue,
            onChanged: _onChanged,
            title: Text('一阶妖灵'),
          ),
          RadioListTile<String>(
            value: '2',
            groupValue: widget.groupValue,
            onChanged: _onChanged,
            title: Text('二阶妖灵'),
          ),
          RadioListTile<String>(
            value: '3',
            groupValue: widget.groupValue,
            onChanged: _onChanged,
            title: Text('三阶妖灵'),
          ),
          RadioListTile<String>(
            value: '4',
            groupValue: widget.groupValue,
            onChanged: _onChanged,
            title: Text('四阶妖灵'),
          ),
          RadioListTile<String>(
            value: '5',
            groupValue: widget.groupValue,
            onChanged: _onChanged,
            title: Text('五阶妖灵'),
          ),
        ],
      )),
    );
  }
}
