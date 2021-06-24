import 'package:fishnet/domain/entity/Trade.dart';
import 'package:fishnet/domain/entity/Variety.dart';
import 'package:fishnet/persistences/PersistenceLayer.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'colors/CardColor.dart';
import 'colors/CardColorImpl1.dart';
import 'domain/dto/PriceNumberPair.dart';
import 'domain/entity/TwoDirectionTransactions.dart';

class GridTransactionList extends StatefulWidget {
  int _varietyId;
  num _currentPrice;

  GridTransactionList(this._varietyId, this._currentPrice);

  @override
  State<StatefulWidget> createState() {
    return _GridTransactionListState();
  }
}


CardColor cardColor = CardColorImpl1();


DateFormat yyyyMMddFormat = DateFormat("yyyy.MM.dd");
DateFormat yyyy_MM_ddFormat = DateFormat("yyyy-MM-dd");

class _GridTransactionListState extends State<GridTransactionList> {
  var _transactions = <TwoDirectionTransactions>[];
  Variety _variety;
  @override
  void initState() {
    updateParentState();
  }


  Future<void> updateParentState() async {
    _variety = await getByVarietyId(widget._varietyId);
    if(_variety == null) {
      Fluttertoast.showToast(
          msg: "_variety为空， 内部错误",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    _transactions = _variety.transactions;
    setState(() {
    });
  }


  static const double _leftRightPadding = 12;

  Widget xxx(int index) {

    var transaction = _transactions[index];
    var cardGlobalKey = GlobalKey();

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails detail) {
        _showMenu(detail, cardGlobalKey, index);
      },
      child: Card(
          key: cardGlobalKey,
          color: transaction.totalProfit(widget._currentPrice) >= 0 ? cardColor.flatBgColor : cardColor.lossBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: Column(
            children: buildChildrenWidget(transaction),
          )),
    );
  }

  List<Widget> buildChildrenWidget(TwoDirectionTransactions transaction) {
    var list =  [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(_leftRightPadding, 12 ,12 ,6 ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFFD5F3F4), Color(0xFFD7FFF0)]), //背景渐变
                        shape: BoxShape.circle,
                        boxShadow: [
                          //阴影
                          BoxShadow(
                              color: Colors.black54,
                              blurRadius: 0.1)
                        ]),
                    child: Container(
                      height: 40,
                      width: 40,
                      // padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(transaction.level.toString(),
                            textAlign: TextAlign.center,
                            maxLines: 1, style: TextStyle(color: color2, fontSize: 12)),
                      ),
                    ),
                  ),
                ),
                buildKeyValuePair("收益（元）", transaction.totalProfit(widget._currentPrice).objToString(), valueSize: 16.0)
              ],
            ),
            buildFlex([
              buildKeyValuePair("买入价格", transaction.buy.price, fractionDigits: 3),
              buildKeyValuePair("买入数量", transaction.buy.number),
              buildKeyValuePair("买入时间", yyyyMMddFormat.format(transaction.buy.time))
            ]),
          ];

    if(transaction.sell != null) {
      list.add(buildFlex([
        buildKeyValuePair("卖出价格", transaction.sell.price, fractionDigits: 3),
        buildKeyValuePair("卖出数量", transaction.sell.number),
        buildKeyValuePair("持有天数", transaction.holdingDays())
      ]));
    }
    return list;
  }

  Padding buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_leftRightPadding, 0, _leftRightPadding, 0),
      child: Divider(height: 0.5, color: Colors.white),
    );
  }

  Widget buildFlex(List<Expanded> expandeds) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_leftRightPadding, 3, _leftRightPadding, 3),
      child: Flex(
        direction: Axis.horizontal,
        children: expandeds,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    var child;
    if (_transactions.isEmpty) {
        child =  Center(
          child: Text(
            "还没有数据哦",
            textAlign: TextAlign.center,
            style: TextStyle(color: color1, fontSize: 12),
          ),
        );
    } else {
      child = Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: xxx(index),
                );
              },
            ),
          )
        ],
      );
    }

    return Scaffold(
      floatingActionButton: MyAddTradeFloat(_variety, updateParentState),
      body: Container(
        color: Colors.white,
        child: child,
      ),
    );
  }

  Widget buildItemCard(int index) {
    var transaction = _transactions[index];
    var cardGlobalKey = GlobalKey();
    Widget card = Card(
      key: cardGlobalKey,
      color: transaction.totalProfit(widget._currentPrice) >= 0 ? cardColor.flatBgColor : cardColor.lossBgColor,
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
            onLongPressStart: (LongPressStartDetails detail) {
              _showMenu(detail, cardGlobalKey, index);
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

  Future<void> _showMenu(LongPressStartDetails detail,
      GlobalKey<State<StatefulWidget>> cardGlobalKey, int index) async {
    // RenderBox renderBox = cardGlobalKey.currentContext.findRenderObject();
    // var offset = renderBox.localToGlobal(Offset(0.0, renderBox.size.height));
    // return offset.dy;

    var findRenderObject =
        (cardGlobalKey.currentContext.findRenderObject() as RenderBox);
    var dy = findRenderObject.localToGlobal(Offset.zero).dy;
    var item = await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            detail.globalPosition.dx, dy, detail.globalPosition.dx, dy),
        items: <PopupMenuItem<String>>[
          new PopupMenuItem<String>(value: 'edit', child: new Text('编辑')),
          new PopupMenuItem<String>(value: 'remove', child: new Text('删除')),
        ]);
    if (item == "edit") {
      showDialog(
          context: context,
          builder: (context) {
            return _editorDialogBuilder(context, index);
          });
    }
    if (item == "remove") {
      showDialog(
          context: context,
          builder: (context) {
            return _deleteDialogBuilder(context, index);
          });
    }
  }

  AlertDialog _editorDialogBuilder(BuildContext context, int index) {
    var transaction = _transactions[index];

    var buyNumber = transaction.buy.number;
    var buyPrice = transaction.buy.price;
    var sellNumber = transaction.sell?.number;
    var sellPrice = transaction.sell?.price;

    var columnChildren = [
      numberFieldInputWidget("买入数量",  (number) => buyNumber = number,  isPrice: true, defaultValue: buyNumber),
      // buildTimePicker(context, "买入时间", buyDate, (date) => buyDate = date),
    ];

    if (transaction.sell != null) {
      columnChildren.add(numberFieldInputWidget("卖出价格", (price) => sellPrice = price, isPrice: true, defaultValue: sellPrice, limit: 7));
      columnChildren.add(numberFieldInputWidget("卖出数量", (number) => sellNumber = number, defaultValue: sellNumber));
    }

    return AlertDialog(
      title: Text("修改"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: columnChildren,
      ),
      actions: <Widget>[
        TextButton(
          child: Text("取消"),
          onPressed: () => Navigator.of(context).pop(), //关闭对话框
        ),
        TextButton(
          child: Text("确认"),
          onPressed: () {
            setState(() {
              // todo 持久化
            });
            Navigator.of(context).pop(true); //关闭对话框
          },
        ),
      ],
    );
  }

  Widget buildTimePicker(
      BuildContext context, String title, DateTime date, Function onChange) {
    return customFieldInputWidget(
        title,
        InkWell(
          onTap: () async {
            var _result = await showDatePicker(
              context: context,
              currentDate: DateTime.now(),
              initialDate: date,
              firstDate: DateTime(2015),
              lastDate: DateTime.now(),
              locale: Locale('zh'),
            );
            if (_result == null) {
              return;
            }
            setState(() {
              date = _result;
            });
            setState(() {
              date = _result;
              onChange(date);
              print(date);
            });
          },
          child: Text(yyyy_MM_ddFormat.format(date)),
        ));
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
            "卖出", transaction.sell == null ? "-" : transaction.sell.price,
            fractionDigits: 3),
        buildKeyValuePair(
            "数量", transaction.sell == null ? "-" : transaction.sell.number)
      ],
    );
  }

  Container div() {
    return Container(
        width: 10, height: 30, child: VerticalDivider(color: Colors.grey));
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
                // offset: Offset(1.0, 1.0),
                blurRadius: 0.1)
          ]),
      child: Container(
        height: 40,
        width: 40,
        // padding: EdgeInsets.all(8),
        child: Center(
          child: Text(value.toString(),
              textAlign: TextAlign.center,
              maxLines: 1, style: TextStyle(color: color, fontSize: 12)),
        ),
      ),
    );
  }

  Expanded buildKeyValuePair(String title, Object value,
      {Color valueColor,
        Color titleColor,
        fractionDigits = 2,
        titleSize = 12.0,
        valueSize = 13.0}) {

    if(valueColor == null) {
      valueColor = cardColor.highEmphasisColor;
    }
    if(titleColor == null) {
      titleColor = cardColor.mediumEmphasisColor;
    }
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
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
                child: new Text(value.objToString(fractionDigits),
                    style: TextStyle(color: valueColor, fontSize: valueSize)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyAddTradeFloat extends StatefulWidget {

  Variety _variety;
  Function updateParentState;

  MyAddTradeFloat(this._variety, this.updateParentState);

  @override
  _MyAddTradeFloatState createState() => _MyAddTradeFloatState();
}

class _MyAddTradeFloatState extends State<MyAddTradeFloat> {
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(fontSize: 16);
    return SpeedDial(
      marginRight: 25, //右边距
      marginBottom: 50, //下边距
      animatedIcon: AnimatedIcons.menu_close, //带动画的按钮
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: true, //是否显示按钮
      closeManually: false, //是否在点击子按钮后关闭展开项
      curve: Curves.bounceIn, //展开动画曲线
      overlayColor: Colors.black, //遮罩层颜色
      overlayOpacity: 0.5, //遮罩层透明度
      onOpen: () => print('OPENING DIAL'), //展开回调
      onClose: () => print('DIAL CLOSED'), //关闭回调
      tooltip: 'Speed Dial', //长按提示文字
      heroTag: 'speed-dial-hero-tag', //hero标记
      backgroundColor: Colors.blue, //按钮背景色
      foregroundColor: Colors.white, //按钮前景色/文字色
      elevation: 8.0, //阴影
      shape: CircleBorder(), //shape修饰
      children: [ //子按钮
        SpeedDialChild(
            child: Icon(Icons.accessibility),
            backgroundColor: Colors.red,
            label: '快速卖出',
            labelStyle: textStyle,
            onTap: () {

              var quickOperate = widget._variety.quickOperate(false);

              if(quickOperate == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("暂时没有可以卖出的了"),
                ));
              } else {
                _showQuickSellDialog(context, quickOperate, false, (price, number) {
                  Trade sell = Trade(id(), price, number, DateTime.now());

                  var ts = [];
                  ts.addAll(widget._variety.transactions);
                  ts.sort((a, b) => b.buy.time.microsecond.compareTo(a.buy.time.microsecond));
                  for (var transaction in ts) {
                    if (transaction.level == quickOperate.level && transaction.sell == null) {
                      transaction.sell = sell;
                    }
                  }
                  saveVariety(widget._variety);
                  widget.updateParentState();
                });
              }

            }),
        SpeedDialChild(
          child: Icon(Icons.brush),
          backgroundColor: Colors.orange,
          label: '快速买入',
          labelStyle: textStyle,
          onTap: () {

            var quickOperate = widget._variety.quickOperate(true);

            if(quickOperate == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("你的网已经被击穿！"),
              ));
            } else {
              _showQuickSellDialog(context, quickOperate, true, (price, number) {
                Trade buy = Trade(id(), price, number, DateTime.now());
                var twoDirectionTransactions = TwoDirectionTransactions(id(), quickOperate.level, buy, null);
                widget._variety.transactions.add(twoDirectionTransactions);
                saveVariety(widget._variety);
                widget.updateParentState();
              });
            }

          },
        ),
      ],
    );
  }

  Future<void> _showQuickSellDialog(BuildContext context, PriceNumberPair priceNumber, bool buy, Function onOkButton) {
    num _price;
    num _number;
    var title = buy ? "买入" : "卖出";
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
        title: Text("快速$title 档位 ${priceNumber.level}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            numberFieldInputWidget("$title价格", (price) => {_price = price}, isPrice: true, defaultValue: priceNumber.price, limit: 7),
            numberFieldInputWidget("$title数量", (num) => {_number = num}, defaultValue: priceNumber.number),
          ],
        ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
                child: Text('确认'),
                onPressed: () {
                  onOkButton(_price, _number);
                  Navigator.of(context).pop();
                }
            ),
          ],
      );
      },
    );
  }
}
