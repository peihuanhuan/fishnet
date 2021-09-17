import 'package:fishnet/NewTransaction.dart';
import 'package:fishnet/domain/dto/Operator.dart';
import 'package:fishnet/domain/entity/Trade.dart';
import 'package:fishnet/domain/entity/Variety.dart';
import 'package:fishnet/persistences/PersistenceLayer.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import 'EditTransaction.dart';
import 'colors/CardColor.dart';
import 'colors/CardColorImpl1.dart';
import 'colors/CardColorImpl2.dart';
import 'domain/dto/PriceNumberPair.dart';
import 'domain/entity/TwoDirectionTransactions.dart';

class GridTransactionList extends StatefulWidget {
  int _varietyId;
  num _currentPrice;

  GridTransactionList(this._varietyId, this._currentPrice);

  @override
  State<StatefulWidget> createState() {
    return _GridTransactionListState(_currentPrice);
  }
}


DateFormat yyyyMMddFormat = DateFormat("yyyy.MM.dd");
DateFormat yyyy_MM_ddFormat = DateFormat("yyyy-MM-dd");

class _GridTransactionListState extends State<GridTransactionList> {
  var _transactions = <TwoDirectionTransactions>[];
  Variety _variety;
  num _currentPrice;

  _GridTransactionListState(this._currentPrice);

  @override
  void initState() {
    updateParentState();
  }

  Future<void> updateParentState() async {
    _variety = await getByVarietyId(widget._varietyId);
    if (_variety == null) {
      toast("_variety为空， 内部错误");
    }
    _transactions = _variety.transactions;
    setState(() {});
  }

  Widget buildCardItem(int index) {
    var transaction = _transactions[index];
    var cardGlobalKey = GlobalKey();

    Widget child = Padding(
      padding: const EdgeInsets.fromLTRB(0,0,0,15),
      child: Column(
        children: buildChildrenWidget(transaction),
      ),
    );
    if(transaction.sell != null) {
      child = ClipRect(
        child: Banner(
          message: "👍🏻",
          location: BannerLocation.topEnd,
          color: Color(0xffFF8C64),
          child: child,
        ),
      );
    }

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails detail) {
        _showMenu(detail, cardGlobalKey, index);
      },
      child: Card(
          key: cardGlobalKey,
          color: getBgColor(transaction.totalProfit(widget._currentPrice), activeCardColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: child),
    );
  }

  List<Widget> buildChildrenWidget(TwoDirectionTransactions transaction) {
    var list = [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(leftRightPadding, 12, 12, 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xaaFF8C64), Color(0xaaFF8C64)]), //背景渐变
                  shape: BoxShape.circle,
                  boxShadow: [
                    //阴影
                    // BoxShadow(color: Colors.yellow, blurRadius: 0.1)
                  ]),
              child: Container(
                height: 40,
                width: 40,
                // padding: EdgeInsets.all(8),
                child: Center(
                  child: Text(transaction.level.toString(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12)),
                ),
              ),
            ),
          ),
          buildKeyValuePair("收益（元）", transaction.totalProfit(widget._currentPrice).objToString(),
              titleSize: 11.0,
              valueSize: 16.0,
              valueColor: getMoneyColor(transaction.totalProfit(widget._currentPrice), activeCardColor))
        ],
      ),
      buildFlex([
        buildKeyValuePair("买入价格", transaction.buy.price, fractionDigits: 3),
        buildKeyValuePair("买入份额", transaction.buy.number),
        buildKeyValuePair("买入时间", yyyyMMddFormat.format(transaction.buy.time))
      ]),
    ];

    if (transaction.sell != null) {
      list.add(buildFlex([
        buildKeyValuePair("卖出价格", transaction.sell.price, fractionDigits: 3),
        buildKeyValuePair("卖出份额", transaction.sell.number),
        buildKeyValuePair("持有天数", transaction.holdingDays())
      ]));
    }
    return list;
  }

  Padding buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(leftRightPadding, 0, leftRightPadding, 0),
      child: Divider(height: 0.5, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    var child;
    if (_transactions.isEmpty) {
      child = Center(
        child: Text(
          "还没有数据哦",
          textAlign: TextAlign.center,
          style: TextStyle(color: activeCardColor.lowEmphasisColor, fontSize: 12),
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
                  child: buildCardItem(index),
                );
              },
            ),
          )
        ],
      );
    }

    return Scaffold(
      floatingActionButton: MyAddTradeFloat(_variety, _currentPrice, updateParentState),
      body: Container(
        color: activeCardColor.bgColor,
        child: child,
      ),
    );
  }

  Future<void> _showMenu(
      LongPressStartDetails detail, GlobalKey<State<StatefulWidget>> cardGlobalKey, int index) async {
    var transaction = _transactions[index];

    List<PopupMenuEntry<String>> popupMenuItems = [];
    if (transaction.sell == null) {
      popupMenuItems.add(
        PopupMenuItem<String>(value: 'sell', child: new Text('卖出')),
      );
    }
    popupMenuItems.add(PopupMenuItem<String>(value: 'edit', child: new Text('编辑')));
    popupMenuItems.add(
      PopupMenuItem<String>(value: 'remove', child: new Text('删除')),
    );

    var findRenderObject = (cardGlobalKey.currentContext.findRenderObject() as RenderBox);
    var dy = findRenderObject.localToGlobal(Offset.zero).dy;
    var item = await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(detail.globalPosition.dx, dy, detail.globalPosition.dx, dy),
        items: popupMenuItems);
    if (item == "edit") {

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EditTransaction(_variety, transaction);
      })).then((value) {
        updateParentState();
      });
    }
    if (item == "remove") {
      showDialog(
          context: context,
          builder: (context) {
            return _deleteDialogBuilder(context, index);
          });
    }

    if (item == "sell") {

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return NewTransaction(_variety, widget._currentPrice, false, transaction.id);
      })).then((value) {
        updateParentState();
      });

    }
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
              _transactions.removeAt(index);
              saveVariety(_variety);
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
        buildKeyValuePair("份额", transaction.buy.number),
        div(),
        buildKeyValuePair("卖出", transaction.sell == null ? "-" : transaction.sell.price, fractionDigits: 3),
        buildKeyValuePair("份额", transaction.sell == null ? "-" : transaction.sell.number)
      ],
    );
  }

  Container div() {
    return Container(width: 10, height: 30, child: VerticalDivider(color: Colors.grey));
  }

  Expanded buildKeyValuePair(String title, Object value,
      {Color valueColor, Color titleColor, fractionDigits = 2, titleSize = 12.0, valueSize = 13.0}) {
    if (valueColor == null) {
      valueColor = activeCardColor.highEmphasisColor;
    }
    if (titleColor == null) {
      titleColor = activeCardColor.mediumEmphasisColor;
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
  num _currentPrice;

  Function updateParentState;

  MyAddTradeFloat(this._variety, this._currentPrice, this.updateParentState);

  @override
  _MyAddTradeFloatState createState() => _MyAddTradeFloatState();
}

class _MyAddTradeFloatState extends State<MyAddTradeFloat> {
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(fontSize: 16);
    return SpeedDial(
      marginRight: 25,
      //右边距
      marginBottom: 50,
      //下边距
      animatedIcon: AnimatedIcons.menu_close,
      //带动画的按钮
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: true,
      //是否显示按钮
      closeManually: false,
      //是否在点击子按钮后关闭展开项
      curve: Curves.bounceIn,
      //展开动画曲线
      overlayColor: Colors.black,
      //遮罩层颜色
      overlayOpacity: 0.5,
      //遮罩层透明度
      // onOpen: () => print('OPENING DIAL'), //展开回调
      // onClose: () => print('DIAL CLOSED'), //关闭回调
      // tooltip: 'Speed Dial', //长按提示文字
      // heroTag: 'speed-dial-hero-tag', //hero标记
      backgroundColor: Colors.blue,
      //按钮背景色
      foregroundColor: Colors.white,
      //按钮前景色/文字色
      elevation: 8.0,
      //阴影
      shape: CircleBorder(),
      //shape修饰
      children: [
        //子按钮
        SpeedDialChild(
            child: Icon(Icons.accessibility),
            backgroundColor: Colors.red,
            label: '卖出',
            labelStyle: textStyle,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NewTransaction(widget._variety, widget._currentPrice, false);
              })).then((value) {
                  widget.updateParentState();
              });
              }
            ),
        SpeedDialChild(
          child: Icon(Icons.brush),
          backgroundColor: Colors.orange,
          label: '买入',
          labelStyle: textStyle,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return NewTransaction(widget._variety, widget._currentPrice, true);
            })).then((value) {
              widget.updateParentState();
            });
          },
        ),

      ],
    );
  }
}

Future<void> _showQuickOperateDialog(BuildContext context, bool buy, Operator operator, String title, Function onOkButton) {
  num _price;
  num _number;

  PriceNumberPair priceNumber = operator.priceNumberPair;

  StatefulBuilder x = StatefulBuilder(
    builder: (context, state) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Offstage(
              // 是否显示
              offstage: operator.extraMessage == null,
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    operator.extraMessage ?? "",
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  )),
            ),
            numberFieldInputWidget("${buy?"买入":"卖出"}价格", (price) => {_price = price},
                isPrice: true, defaultValue: priceNumber.price, limit: 7),
            numberFieldInputWidget("${buy?"买入":"卖出"}份额", (num) => {_number = num}, defaultValue: priceNumber.number),
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
                if (onOkButton(_price, _number)) {
                  Navigator.of(context).pop();
                }
              }),
        ],
      );
    },
  );
  return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (context) {
        return x;
      });
}