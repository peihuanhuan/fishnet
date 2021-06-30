import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'PrecisionLimitFormatter.dart';

const double leftRightPadding = 22;

var cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(24.0)),
);


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
                child: new Text(value.objToString(), style: TextStyle(color: valueColor, fontSize: valueSize, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget numberFieldInputWidget(String title, Function onChange,
    {int maxLength, bool isPrice = false, int limit = 8, hintText, num defaultValue}) {
  if (defaultValue != null) {
    onChange(defaultValue);
  }
  return customFieldInputWidget(
      title,
      TextField(
        decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(fontSize: 12)),
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
          }
        },
      ));
}

Widget stringFieldInputWidget(String title, Function onChange, {int limit = 8, hintText, defaultValue = ""}) {
  if (defaultValue != null) {
    onChange(defaultValue);
  }
  return customFieldInputWidget(
      title,
      TextField(
        decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(fontSize: 12)),
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
  return Flex(
    direction: Axis.horizontal,
    children: [
      Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Text(
            title + ":",
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
      Expanded(flex: 4, child: valueChild)
    ],
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
