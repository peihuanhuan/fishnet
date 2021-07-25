import 'dart:ui';

import 'package:fishnet/colors/CardColorImpl2.dart';
import 'package:flutter/cupertino.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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


TextField buildNumberField(Function function, {isTop = false, isBottom = false, String defaultValue, String title = "数量", int maxLength = 8, hintText = "输入100的倍数", readOnly = false}) {
  return TextField(
      onChanged: (str) {
        if (str.isNotEmpty) {
          function(num.parse(str));
        } else {
          function(-1);
        }
      },
      readOnly: readOnly,
      textAlign: TextAlign.right,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
        FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
      ],
      controller: defaultValue == null ? null : TextEditingController.fromValue(TextEditingValue(
          text: defaultValue,
          // 保持光标在最后
          selection: TextSelection.fromPosition(TextPosition(
              affinity: TextAffinity.downstream, offset: defaultValue.length)))),
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly ? Colors.white54 : Colors.white,
        prefixText: title,
        labelText: title,
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
        prefixStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
        hintText: hintText,
        border: OutlineInputBorder(
            borderRadius: borderRadius(isTop, isBottom),
            borderSide: BorderSide.none),
      ));
}


Container buildDiv() {
  return Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(left: 12.0, right: 12.0),
        color: activeCardColor.lowEmphasisColor,
        height: 0.2,
      ));
}


TextField buildPriceField(Function function, {isTop = false, isBottom = false, String defaultValue, String title = "价格", readOnly = false}) {
  return TextField(
    onChanged: (str) {
      if (str.isNotEmpty) {
        function(num.parse(str));
      } else {
        function(-1);
      }
    },
    readOnly: readOnly,
    textAlign: TextAlign.right,
    inputFormatters: <TextInputFormatter>[
      PrecisionLimitFormatter(3),
      LengthLimitingTextInputFormatter(8),
      FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
    ],
    controller: defaultValue == null ? null : TextEditingController.fromValue(TextEditingValue(
        text: defaultValue,
        // 保持光标在最后
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: defaultValue.length)))),
    decoration: InputDecoration(
      filled: true,
      fillColor: readOnly ? Colors.white54 : Colors.white,
      prefixText: title,
      labelText: title,
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      prefixStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
      labelStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
      border: OutlineInputBorder(
          borderRadius: borderRadius(isTop, isBottom),
          borderSide: BorderSide.none),
    ),
  );
}

TextField buildStringField(Function function, {isTop = false, isBottom = false, String defaultValue, String title = "价格", autofocus = false, hintText, maxLength = 10, readOnly = false}) {
  return TextField(
    onChanged: (str) {
        function(str);
    },
    autofocus: autofocus,
    readOnly: readOnly,
    textAlign: TextAlign.right,
    inputFormatters: <TextInputFormatter>[
      LengthLimitingTextInputFormatter(maxLength),
    ],
    controller: defaultValue == null ? null : TextEditingController.fromValue(TextEditingValue(
        text: defaultValue,
        // 保持光标在最后
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: defaultValue.length)))),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixText: title,
      labelText: title,
      hintText: hintText,
      alignLabelWithHint: true,
      prefixStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
      labelStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: OutlineInputBorder(
          borderRadius: borderRadius(isTop, isBottom),
          borderSide: BorderSide.none),
    ),
  );
}

BorderRadius borderRadius(bool isTop, bool isBottom) {
  double value = 8;
  Radius top;
  Radius bottom;
  if(isTop) {
    top = Radius.circular(value);
  } else {
    top = Radius.zero;
  }

  if(isBottom) {
    bottom = Radius.circular(value);
  } else {
    bottom = Radius.zero;
  }
  return BorderRadius.vertical(top: top, bottom: bottom);
}

TextField buildDateField(BuildContext context, DateTime initDate, Function onChange) {
  return TextField(
    onTap: () async {
      var _result = await showDatePicker(
        context: context,
        currentDate: DateTime.now(),
        initialDate: initDate,
        firstDate: DateTime(2015),
        lastDate: DateTime.now(),
        locale: Locale('zh'),
      );
      if (_result != null) {
        onChange(_result);
      }
    },
    textAlign: TextAlign.right,
    controller: (TextEditingController()
      ..text = (initDate.difference(DateTime.now()).inDays == 0 ? "今天" : DateFormat("yyyy-MM-dd").format(initDate))),
    readOnly: true,
    showCursor: false,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixText: "日期",
      prefixStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
      labelStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: UnderlineInputBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8)),
          borderSide: BorderSide.none),
    ),
  );
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
