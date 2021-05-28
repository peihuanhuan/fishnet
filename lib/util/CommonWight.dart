import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:flutter/material.dart';


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





