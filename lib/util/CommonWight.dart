import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'PrecisionLimitFormatter.dart';


const double _left = 22;

const Color color4 = Color(0xFF3EB595);

const Color color3 = Color(0xFFFF665A);

const Color color2 = Color(0xFF7D6B7D);

const Color color1 = Color(0xFFA3A1A8);



Expanded buildKeyValuePair(String title, Object value, {Color color = color2, titleSize = 12.0, valueSize = 24.0}) {
  return Expanded(
    flex: 1,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_left, 10, 8, 8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: TextStyle(color: color1, fontSize: titleSize), textAlign: TextAlign.left,),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: new Text(value.objToString(), style: TextStyle(color: color, fontSize: valueSize)),
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

  if(defaultValue != null) {
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
          !isPrice
              ? FilteringTextInputFormatter.digitsOnly
              : PrecisionLimitFormatter(3),
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

Widget stringFieldInputWidget(String title, Function onChange,
    {int limit = 8, hintText, defaultValue = ""}) {
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
      Expanded(
          flex: 4,
          child: valueChild)
    ],
  );
}


Color getFontColor(Object value) {
  var normal = Color(0xFF7D6B7D);
  if(!(value is num)) {
    return normal;
  }
  if(value as num < 0) {
    return Color(0xFF3EB595);
  }
  if(value == 0) {
    return normal;
  }
  return Color(0xFFFF665A);
}





