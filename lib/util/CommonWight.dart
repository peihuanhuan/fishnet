import 'dart:ui';

import 'package:fishnet/colors/CardColorImpl2.dart';
import 'package:flutter/cupertino.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'PrecisionLimitFormatter.dart';


var activeCardColor = CardColorImpl2();


const double leftRightPadding = 22;

var cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(24.0)),
);


void toast(String msg, {bool long = false}) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: long ? Toast.LENGTH_LONG: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: long ? 5: 1,
      backgroundColor: Color(0xff333333),
      textColor: Color(0xffFCFCFC),
      fontSize: 14.0);
}

Widget buildFlex(List<Expanded> expandeds) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(leftRightPadding, 3, leftRightPadding, 3),
    child: Flex(
      direction: Axis.horizontal,
      children: expandeds,
    ),
  );
}

Expanded buildKeyValuePair(String title, Object value,
    {Color titleColor, int flex = 1, Color valueColor, titleSize = 12.0, valueSize = 16.0}) {
  return Expanded(
    flex: flex,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(leftRightPadding, 10, 8, 8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(color: titleColor, fontSize: titleSize),
                textAlign: TextAlign.left,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: new Text(value.objToString(),
                    style: TextStyle(color: valueColor, fontSize: valueSize, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget numberFieldInputWidget(String title, Function onChange,
    {int maxLength, bool isPrice = false, int limit = 8, hintText, helperText, num defaultValue}) {
  if (defaultValue != null) {
    onChange(defaultValue);
  }
  return (
      // title,
      TextField(
        decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(fontSize: 12),
          labelText: title,
          helperText: helperText
        ),
        controller: defaultValue == null ? null : (TextEditingController()..text = defaultValue.toString()),
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        inputFormatters: <TextInputFormatter>[
          !isPrice ? FilteringTextInputFormatter.digitsOnly : PrecisionLimitFormatter(3),
          LengthLimitingTextInputFormatter(limit),
          FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
        ],
        onChanged: (str) {
          if (str.isNotEmpty) {
            onChange(num.parse(str));
          } else {
            onChange(0);
          }
        },
      ));
}

Widget stringFieldInputWidget(String title, Function onChange, {int limit = 8,helperText, hintText, defaultValue = ""}) {
  if (defaultValue != null) {
    onChange(defaultValue);
  }
  return (
      // title,
      TextField(
        decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(fontSize: 12),
          labelText: title,
        helperText: helperText),
        keyboardType: TextInputType.text,
        controller: TextEditingController()..text = defaultValue.toString(),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.singleLineFormatter,
          LengthLimitingTextInputFormatter(limit),
        ],
        onChanged: (str) {
          onChange(str);
        },
      ));
}

Widget customFieldInputWidget(String title, Widget valueChild) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
    child: Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title + ":",
            style: TextStyle(fontSize: 14),
          ),
        ),
        Expanded(flex: 4, child: valueChild)
      ],
    ),
  );
}

Color getFontColor(Object value) {
  var normal = Color(0xFF7D6B7D);
  if (!(value is num)) {
    return normal;
  }
  if (value as num < 0) {
    return Color(0xFF3EB595);
  }
  if (value == 0) {
    return normal;
  }
  return Color(0xFFFF665A);
}
