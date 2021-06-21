import 'package:fishnet/colors/CardColor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardColorImpl2 implements CardColor {
  @override
  Color flatBgColor = Colors.white;

  @override
  Color lossBgColor = Colors.white;

  @override
  Color profitBgColor = Colors.white;

  @override
  Color mediumEmphasisColor = Color(0xFFA3A1A8);

  @override
  Color highEmphasisColor = Color(0xFF7D6B7D);

  @override
  Color lowEmphasisColor = Color(0xDDA3A1A8);

}