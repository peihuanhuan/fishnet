import 'package:auto_size_text/auto_size_text.dart';
import 'package:fishnet/entity/TwoDirectionTransactions.dart';
import 'package:fishnet/persistences/PersistenceLayer.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'MyCardItem.dart';
import 'entity/Trade.dart';

class GridTransactionList extends StatefulWidget {
  int _varietyId;
  num _currentPrice;

  GridTransactionList(this._varietyId, this._currentPrice);

  @override
  State<StatefulWidget> createState() {
    return _GridTransactionListState();
  }
}

Color c1 = Color(0xFFFEF1FA);
Color c2 = Color(0xFFEBF6FF);
Color c3 = Color(0xFFFAF2FE);
Color c4 = Color(0xFFFBF4E5);

List<Color> cc = [c1, c2, c3, c4];

DateFormat yyyyMMddFormat = DateFormat("yyyy.MM.dd");

class _GridTransactionListState extends State<GridTransactionList> {
  var _transactions = <TwoDirectionTransactions>[];

  @override
  void initState() {
    var variety = getByVarietyId(widget._varietyId);
    _transactions = variety.transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: buildFlex(index),
                );
              },
              // separatorBuilder: (context, index) => Divider(height: .0),
            ),
          )
        ],
      ),
    );
  }

  Widget buildFlex(int index) {
    var transaction = _transactions[index];
    Widget card = Card(
      color: cc[index % 4],
      child: ExpansionTile(
        tilePadding: EdgeInsets.fromLTRB(0, 0, 8, 0),
        childrenPadding: EdgeInsets.all(0),
        trailing: Text(
            "￥${transaction.totalProfit(widget._currentPrice).objToString()}",
            style: TextStyle(
                fontSize: 15,
                color: getFontColor(
                    transaction.totalProfit(widget._currentPrice)))),
        leading: buildLeading("${transaction.level}"),
        title: buildTitle(transaction),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                buildKeyValuePair(
                    "买入时间", yyyyMMddFormat.format(transaction.buy.time)),
                buildKeyValuePair("持有天数", transaction.holdingDays()),
                buildKeyValuePair("年化率",
                    "${toPercentage(transaction.annualizedRate(widget._currentPrice))}"),
                buildKeyValuePair("留存数量", transaction.retainedNumber()),
                Icon(
                  Icons.edit,
                  color: color2,
                ),
                Icon(Icons.delete),
              ],
            ),
          ),
        ],
      ),
    );

    return card;
  }

  Flex buildTitle(TwoDirectionTransactions transaction) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        buildKeyValuePair("买入", transaction.buy.price, fractionDigits: 3),
        buildKeyValuePair("数量", transaction.buy.number),
        div(),
        buildKeyValuePair(
            "卖出", transaction.sell == null ? 0 : transaction.sell.price,
            fractionDigits: 3),
        buildKeyValuePair(
            "数量", transaction.sell == null ? 0 : transaction.sell.number)
      ],
    );
  }

  Container div() {
    return Container(
        width: 10, height: 30, child: VerticalDivider(color: Colors.grey));
  }

  Expanded buildExpanded(int flex, String title, num price, int count,
      {Color color = color2}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(color: color1, fontSize: 8),
                textAlign: TextAlign.left,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: new Text("$price * $count = ￥${price * count}",
                    style: TextStyle(color: color, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLeading(Object value, {Color color = color2}) {
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFD5F3F4), Color(0xFFD7FFF0)]), //背景渐变
          shape: BoxShape.circle,
          boxShadow: [
            //阴影
            BoxShadow(
                color: Colors.black54,
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0)
          ]),
      child: Container(
        padding: EdgeInsets.all(8),
        child: AutoSizeText(value.toString(),
            maxLines: 1, style: TextStyle(color: color, fontSize: 18)),
      ),
    );
  }

  Expanded buildKeyValuePair(String title, Object value,
      {Color color = color2,
      fractionDigits = 2,
      titleSize = 12.0,
      valueSize = 14.0}) {
    return Expanded(
      flex: 1,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 0, 8),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(color: color1, fontSize: titleSize),
                  textAlign: TextAlign.left,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                  child: new Text(value.objToString(fractionDigits),
                      style: TextStyle(color: color, fontSize: valueSize)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
