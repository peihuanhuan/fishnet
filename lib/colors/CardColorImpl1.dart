import 'package:fishnet/colors/CardColor.dart';
import 'package:flutter/cupertino.dart';

class CardColorImpl1 implements CardColor {
  @override
  Color flatBgColor = Color(0xDDFF9E40);

  @override
  Color lossBgColor = Color(0xDD54B862);

  @override
  Color profitBgColor = Color(0xDDFF9E40);



  
  // wenzi  https://material.io/components/text-fields#theming
  @override
  // 60%
  Color mediumEmphasisColor = Color(0x99FFFFFF);

  @override
  // 87%
  Color highEmphasisColor = Color(0xDDFFFFFF);


  // 38%
  @override
  Color lowEmphasisColor = Color(0x60FFFFFF);

}