import 'package:auto_size_text/auto_size_text.dart';
import 'package:fishnet/entity/TwoDirectionTransactions.dart';
import 'package:fishnet/persistences/PersistenceLayer.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'PopupMenu.dart';

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
    if (_transactions.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text(
            "还没有数据哦",
            textAlign: TextAlign.center,
            style: TextStyle(color: color1, fontSize: 12),
          ),
        ),
      );
    }

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
                  child: buildItemCard(index),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildItemCard(int index) {
    var transaction = _transactions[index];
    var cardGlobalKey = GlobalKey();

    Offset globalPosition;
    Widget card = Card(
      key: cardGlobalKey,
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
          GestureDetector(

            // onTapUp: (TapUpDetails detail) {
            //   //获取当前触摸点的全局坐标
            //   globalPosition=detail.globalPosition;
            //   print(globalPosition);
            //   //获取当前触摸点的局部坐标
            //   var localPosition=detail.localPosition;
            // },
            onTapUp: (TapUpDetails detail){

              print(detail.globalPosition);
              print(detail.globalPosition.dx);
              showMenu(
                  context: context,
                  // position: RelativeRect.fromLTRB(100.0, 200.0, 100.0, 100.0),
                  position: RelativeRect.fromLTRB(1, top(cardGlobalKey), 0, 0),
                  items: <PopupMenuItem<String>>[
                    new PopupMenuItem<String>( value: 'value01', child: new Text('Item One')),
                    new PopupMenuItem<String>( value: 'value02', child: new Text('Item Two')),
                  ] );

              // showDialog(
              //     context: context,
              //     builder: (context) {
              //       return _editorDialogBuilder(context, index);
              //     });
            },
            onLongPress: (){

              showDialog(
                  context: context,
                  builder: (context) {
                    return _deleteDialogBuilder(context, index);
                  });

            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  buildKeyValuePair(
                      "买入时间", yyyyMMddFormat.format(transaction.buy.time)),
                  buildKeyValuePair("持有天数", transaction.holdingDays()),
                  buildKeyValuePair("年化率",
                      "${toPercentage(transaction.annualizedRate(widget._currentPrice))}"),
                  buildKeyValuePair("留存数量", transaction.retainedNumber()),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return card;
  }

  double top(GlobalKey<State<StatefulWidget>> cardGlobalKey) {

    var findRenderObject = (cardGlobalKey.currentContext.findRenderObject() as RenderBox);

    // print(findRenderObject.localToGlobal(Offset.zero));
    // print(findRenderObject.size);


    return findRenderObject.localToGlobal(Offset.zero).dy;
  }

  AlertDialog _editorDialogBuilder(BuildContext context, int index) {
    var transaction = _transactions[index];

    var buyNumber = transaction.buy.number;
    var buyPrice = transaction.buy.price;
    var sellNumber = transaction.sell.number;
    var sellPrice = transaction.sell.price;

    return AlertDialog(
      title: Text("修改"),
      content: Column(
        children: [
          buySellNumberTextField("买入数量", buyNumber, (number) => buyNumber = number),
          buySellTextField("买入价格", buyPrice, (price) => buyPrice = price),

          buySellNumberTextField("卖出数量", sellNumber, (number) => sellNumber = number),
          buySellTextField("卖出价格", sellPrice, (price) => sellPrice = price),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text("取消"),
          onPressed: () => Navigator.of(context).pop(), //关闭对话框
        ),
        TextButton(
          child: Text("删除"),
          onPressed: () {
            setState(() {
              // todo 持久化
              _transactions.removeAt(index);
            });
            Navigator.of(context).pop(true); //关闭对话框
          },
        ),
      ],
    );
  }

  TextField buySellNumberTextField(String title, int number, Function onChange) {
    return TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "买入数量"),
          controller: TextEditingController()..text = number.toString(),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10)
          ],
          onChanged: (str) {
            onChange(int.parse(str));
          },
        );
  }

  TextField buySellTextField(String title, num price, Function onChange) {
    return TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: title),
          controller: TextEditingController()..text = price.toString(),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
            LengthLimitingTextInputFormatter(10)
          ],
          onChanged: (str) {
            onChange(num.parse(str));
          },
        );
  }

  AlertDialog _deleteDialogBuilder(BuildContext context, int index) {
    return AlertDialog(
      title: Text("提示"),
      content: Text("确定要删除该波段吗?"),
      actions: <Widget>[
        TextButton(
          child: Text("取消"),
          onPressed: () => Navigator.of(context).pop(), //关闭对话框
        ),
        TextButton(
          child: Text("删除"),
          onPressed: () {
            setState(() {
              // todo 持久化
              _transactions.removeAt(index);
            });
            Navigator.of(context).pop(true); //关闭对话框
          },
        ),
      ],
    );
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
