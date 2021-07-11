import 'dart:convert';
import 'dart:io';

import 'package:fishnet/colors/CardColor.dart';
import 'package:fishnet/colors/CardColorImpl1.dart';
import 'package:fishnet/domain/entity/FoundPrice.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:fishnet/widgets/DeleteVarietyDialog.dart';
import 'package:fishnet/widgets/EditVarietyDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'GridTransactionList.dart';
import 'colors/CardColorImpl2.dart';
import 'domain/entity/Variety.dart';


class StatefulFoundCardItem extends StatefulWidget {
  Variety _variety;
  num _totalMoney;
  FoundPrice _foundPrice;

  Key key;
  Function _remove;
  Function _edit;
  VoidCallback _onTap;

  StatefulFoundCardItem(this._variety, this._totalMoney, this._foundPrice, this.key, this._remove, this._edit, this._onTap)
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

  @override
  Widget build(BuildContext context) {

    var cardGlobalKey = GlobalKey();


    return GestureDetector(
      onTap: widget._onTap,
      onLongPressStart: (LongPressStartDetails detail) async {
        var findRenderObject =
        (cardGlobalKey.currentContext.findRenderObject() as RenderBox);
        var dy = findRenderObject.localToGlobal(Offset.zero).dy;
        var v = await showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
                detail.globalPosition.dx, dy, detail.globalPosition.dx, dy),
            items: <PopupMenuItem<String>>[
              new PopupMenuItem<String>(value: 'edit', child: new Text('修改')),
              new PopupMenuItem<String>(value: 'remove', child: new Text('删除')),
            ]);

        if(v == "remove") {
          showDialog(
            context: context,
            barrierDismissible: true, // user must tap button!
            builder: (BuildContext context) {
              return DeleteVarietyDialog("${widget._variety.code}", (code) => code == widget._variety.code,
                  widget._remove);
            },
          );
        }

        if(v == "edit") {
          showDialog(
            context: context,
            barrierDismissible: true, // user must tap button!
            builder: (BuildContext context) {
              return EditVarietyDialog(widget._variety.name, widget._variety.tag, (name, tag) {widget._edit(name, tag);});
            },
          );
        }

      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: Card(
          key: cardGlobalKey,
            color: getBgColor(widget._variety.totalProfit(widget._foundPrice.price), activeCardColor),
            shape: cardShape,
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(leftRightPadding, 10, leftRightPadding, 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(widget._variety.name.isEmpty ? "-" : widget._variety.name, style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold, color: activeCardColor.highEmphasisColor)),
                          new Text(widget._variety.code, style: TextStyle(fontSize: 12, color: activeCardColor.mediumEmphasisColor)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        alignment: Alignment.bottomLeft,
                        child: new Text(widget._variety.tag ?? "", style: TextStyle(fontSize: 12, color: activeCardColor.mediumEmphasisColor)),
                      ),
                    ),
                    Flexible(fit: FlexFit.tight, child: SizedBox()),
                    // buildKeyValuePair("占比", _buildPercentage(), flex: 2, titleColor: cardColor.mediumEmphasisColor, valueColor: cardColor.highEmphasisColor),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, leftRightPadding, 8),
                      child: Column(
                        children: [
                          Padding(
                            // todo 靠左
                            padding: const EdgeInsets.only(top: 8.0, bottom: 2),
                            child: Align(alignment: Alignment.centerLeft, child: new Text('占比', style: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 10, ))),
                          ),
                          Text(_buildPercentage(), style: TextStyle(color: activeCardColor.highEmphasisColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                buildDivider(),
                buildFlex([
                  buildKeyValuePair("持有金额", widget._variety.holdingAmount(widget._foundPrice.price).outlierDesc(0, "-"),
                      titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.highEmphasisColor),
                  buildKeyValuePair("持有份额", widget._variety.retainedNumber(), titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.highEmphasisColor),
                  buildKeyValuePair("波段次数", widget._variety.twoWayFrequency(), titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.highEmphasisColor),
                ]),
                buildFlex([
                  widget._variety.averageCost() == NO_COST
                      ? buildKeyValuePair("成本", "暂无", flex: 1, titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.lowEmphasisColor, valueSize: 13.0)
                      : buildKeyValuePair("成本", widget._variety.averageCost().objToString(3), flex: 1, titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.highEmphasisColor),

                  widget._foundPrice.price == 0
                      ? buildKeyValuePair("现价", "暂无",flex: 2, valueSize: 13.0, titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.lowEmphasisColor)
                      : buildKeyValuePair("现价 (${_updateTimeStr()})", widget._foundPrice.price.toStringAsFixed(3),flex: 2, titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.highEmphasisColor),
                ]),
                buildDivider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(leftRightPadding, 10, leftRightPadding, 6),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                        child: new Text(
                          '累计收益  ',
                          style: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                        ),
                      ),
                      buildTotalProfitText(),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Text buildTotalProfitText() {
    var totalProfit = widget._variety.totalProfit(widget._foundPrice.price);
    Color color = getMoneyColor(totalProfit, activeCardColor);
    return Text(totalProfit.objToString(), style: TextStyle(color: color, fontSize: 16,fontWeight: FontWeight.bold),);
  }




  String _buildPercentage() {
    if (widget._totalMoney == 0) {
      return "-";
    }
    var percent = widget._variety.holdingAmount(widget._foundPrice.price) / widget._totalMoney;
    return toPercentage(percent);
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
      padding: const EdgeInsets.fromLTRB(leftRightPadding, 0, leftRightPadding, 0),
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
