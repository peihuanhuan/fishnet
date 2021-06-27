import 'package:fishnet/colors/CardColor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardColorImpl2 implements CardColor {


  @override
  Color flatBgColor = Color(0xFFF8F8F8);

  @override
  Color lossBgColor = Color(0xFFF8F8F8);

  @override
  Color profitBgColor = Color(0xFFF8F8F8);

  @override
  Color mediumEmphasisColor = Color(0xFFA3A1A8);

  @override
  Color highEmphasisColor = Color(0xFF7D6B7D);

  @override
  Color lowEmphasisColor = Color(0xDDA3A1A8);

  @override
  Color flatColor = Color(0xFF7D6B7D);

  @override
  Color lossColor = Color(0xDD54B862);

  @override
  Color profitColor = Colors.red;

}