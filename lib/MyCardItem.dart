import 'dart:convert';
import 'dart:io';

import 'package:fishnet/domain/entity/FoundPrice.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'GridTransactionList.dart';
import 'domain/entity/Variety.dart';

class StatefulFoundCardItem extends StatefulWidget {
  Variety _variety;
  num _totalMoney;
  FoundPrice _foundPrice;

  Key key;
  VoidCallback _onLongPress;

  StatefulFoundCardItem(this._variety, this._totalMoney, this._foundPrice,
      this.key, this._onLongPress)
      : super(key: key) {
    if (_foundPrice == null) {
      _foundPrice = FoundPrice(
          _variety.code, 0, DateTime.now().add(Duration(minutes: -60)));
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _FoundCardItem();
  }
}

class _FoundCardItem extends State<StatefulFoundCardItem> {
  static const double _left = 22;

  // var foundPrice = FoundPrice(0, DateTime.now().add(Duration(minutes: -60)));

  @override
  void initState() {
    // checkUpdateFoundPrice(widget._variety.code);
  }

  // checkUpdateFoundPrice(String code, {Function() f}) async {
  //   if (foundPrice == null ||
  //       foundPrice.lastQueryTime.difference(DateTime.now()).inMinutes.abs() >
  //           3) {
  //     foundPrice = await queryPrice(code);
  //     // todo 这里会报警
  //     setState(() {});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GridTransactionList(
              widget._variety.id, widget._foundPrice.price);
        }));
      },
      onLongPress: widget._onLongPress,
      child: Card(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_left, 10, 8, 6),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(widget._variety.name,
                              style: TextStyle(fontSize: 22)),
                          new Text(widget._variety.code,
                              style: TextStyle(fontSize: 12, color: color2)),
                        ],
                      ),
                    ),
                  ),
                  Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: new Text('占比',
                              style: TextStyle(color: color1, fontSize: 10)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: new Text(_buildPercentage(),
                              style: TextStyle(color: color2, fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              buildDivider(),
              buildFlex([
                buildKeyValuePair(
                    "持有金额",
                    widget._variety
                        .holdingAmount(widget._foundPrice.price)
                        .outlierDesc(0, "-")),
                buildKeyValuePair(
                    "资金年化率", toPercentage(widget._variety.annualizedRate()))
              ]),
              buildFlex([
                buildKeyValuePair("实盈", widget._variety.realProfit(),
                    color: getFontColor(widget._variety.realProfit())),
                buildKeyValuePair("波段次数", widget._variety.twoWayFrequency())
              ]),
              buildFlex([
                buildKeyValuePair(
                    "浮盈 (现价 ${_floatingProfitDetail()})", _buildFloatingProfit(),
                    color: getFontColor(_buildFloatingProfit())),
              ]),
              buildDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(_left, 10, 8, 6),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                      child: new Text(
                        '总收益   ',
                        style: TextStyle(color: color2, fontSize: 12),
                      ),
                    ),
                    _buildTotalProfitText(),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Text _buildTotalProfitText() {
    if (widget._foundPrice.price == 0) {
      return new Text("-",
        style: TextStyle(color: getFontColor("-"), fontSize: 16),
      );
    } else {
      var totalProfit = widget._variety.totalProfit(widget._foundPrice.price);
      return new Text(totalProfit.objToString(),
        style: TextStyle(color: getFontColor(totalProfit), fontSize: 16),
      );
    }

  }


  _buildFloatingProfit() {
    if (widget._foundPrice.price == 0) {
      return "-";
    }
    return widget._variety.floatingProfit(widget._foundPrice.price);
  }

  String _buildPercentage() {
    if (widget._totalMoney == 0) {
      return "-";
    }
    var percent = widget._variety.holdingAmount(widget._foundPrice.price) /
        widget._totalMoney;
    return toPercentage(percent);
  }

  String _floatingProfitDetail() {
    if (widget._foundPrice.price == 0) {
      return "-";
    }
    return "${widget._foundPrice.price.toStringAsFixed(3)}，更新于${_updateTimeStr()}";
  }

  String _updateTimeStr() {
    var different =
        DateTime.now().difference(widget._foundPrice.lastQueryTime).inMinutes;
    if (different == 0) {
      return "刚刚";
    }
    return "$different分钟前";
  }

  Padding buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_left, 0, 8, 0),
      child: Divider(height: 0.5, color: Color(0xFFABAA9A)),
    );
  }

  Flex buildFlex(List<Expanded> expandeds) {
    return Flex(
      direction: Axis.horizontal,
      children: expandeds,
    );
  }
}
