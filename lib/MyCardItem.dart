import 'dart:convert';
import 'dart:io';

import 'package:fishnet/colors/CardColor.dart';
import 'package:fishnet/colors/CardColorImpl1.dart';
import 'package:fishnet/domain/entity/FoundPrice.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'GridTransactionList.dart';
import 'colors/CardColorImpl2.dart';
import 'domain/entity/Variety.dart';

CardColor cardColor = CardColorImpl1();

class StatefulFoundCardItem extends StatefulWidget {
  Variety _variety;
  num _totalMoney;
  FoundPrice _foundPrice;

  Key key;
  VoidCallback _onLongPress;
  VoidCallback _onTap;

  StatefulFoundCardItem(this._variety, this._totalMoney, this._foundPrice, this.key, this._onLongPress, this._onTap)
      : super(key: key) {
    if (_foundPrice == null) {
      _foundPrice = FoundPrice(_variety.code, 0, DateTime.now().add(Duration(minutes: -60)));
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _FoundCardItem();
  }
}

class _FoundCardItem extends State<StatefulFoundCardItem> {
  static const double _leftRightPadding = 22;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget._onTap,
      onLongPress: widget._onLongPress,
      child: Card(
          color:
              widget._variety.totalProfit(widget._foundPrice.price) >= 0 ? cardColor.flatBgColor : cardColor.lossBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
          ),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_leftRightPadding, 10, _leftRightPadding, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(widget._variety.name, style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold, color: cardColor.highEmphasisColor)),
                        new Text(widget._variety.code, style: TextStyle(fontSize: 12, color: cardColor.mediumEmphasisColor)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      alignment: Alignment.bottomLeft,
                      child: new Text(widget._variety.tag ?? "", style: TextStyle(fontSize: 12, color: cardColor.mediumEmphasisColor)),
                    ),
                  ),
                  Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, _leftRightPadding, 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: new Text('占比', style: TextStyle(color: cardColor.mediumEmphasisColor, fontSize: 10)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: new Text(_buildPercentage(), style: TextStyle(color: cardColor.highEmphasisColor, fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              buildDivider(),
              buildFlex([
                buildKeyValuePair("持有金额", widget._variety.holdingAmount(widget._foundPrice.price).outlierDesc(0, "-"),
                    titleColor: cardColor.mediumEmphasisColor, valueColor: cardColor.highEmphasisColor),
                buildKeyValuePair("波段次数", widget._variety.twoWayFrequency(), titleColor: cardColor.mediumEmphasisColor, valueColor: cardColor.highEmphasisColor)
              ]),
              buildFlex([
                buildKeyValuePair("现价 (${_updateTimeStr()})", _floatingProfitDetail(), titleColor: cardColor.mediumEmphasisColor, valueColor: cardColor.highEmphasisColor),
                buildKeyValuePair("成本", widget._variety.cost().objToString(3), titleColor: cardColor.mediumEmphasisColor, valueColor: cardColor.highEmphasisColor)
              ]),
              buildFlex([
                buildKeyValuePair("持有", widget._variety.retainedNumber(), titleColor: cardColor.mediumEmphasisColor, valueColor: cardColor.highEmphasisColor),
              ]),
              buildDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(_leftRightPadding, 10, _leftRightPadding, 6),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                      child: new Text(
                        '总收益   ',
                        style: TextStyle(color: cardColor.mediumEmphasisColor, fontSize: 12),
                      ),
                    ),
                    Text(
                      widget._variety.totalProfit(widget._foundPrice.price).objToString(),
                      style: TextStyle(color: cardColor.highEmphasisColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }


  String _buildPercentage() {
    if (widget._totalMoney == 0) {
      return "-";
    }
    var percent = widget._variety.holdingAmount(widget._foundPrice.price) / widget._totalMoney;
    return toPercentage(percent);
  }

  String _floatingProfitDetail() {
    if (widget._foundPrice.price == 0) {
      return "-";
    }
    return "${widget._foundPrice.price.toStringAsFixed(3)}";
  }

  String _updateTimeStr() {
    var different = DateTime.now().difference(widget._foundPrice.lastQueryTime).inMinutes;
    if (different == 0) {
      return "刚刚";
    }
    return "$different分钟前";
  }

  Padding buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_leftRightPadding, 0, _leftRightPadding, 0),
      child: Divider(height: 0.5, color: Colors.white),
    );
  }

  Flex buildFlex(List<Expanded> expandeds) {
    return Flex(
      direction: Axis.horizontal,
      children: expandeds,
    );
  }
}
