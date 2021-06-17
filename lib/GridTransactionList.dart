import 'package:auto_size_text/auto_size_text.dart';
import 'package:fishnet/persistences/PersistenceLayer.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

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

Color c1 = Color(0xFFFEF1FA);
Color c2 = Color(0xFFEBF6FF);
Color c3 = Color(0xFFFAF2FE);
Color c4 = Color(0xFFFBF4E5);

List<Color> cc = [c1, c2, c3, c4];

DateFormat yyyyMMddFormat = DateFormat("yyyy.MM.dd");
DateFormat yyyy_MM_ddFormat = DateFormat("yyyy-MM-dd");

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

    return Scaffold(
      floatingActionButton: MyAddTradeFloat(),
      body: Container(
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
      ),
    );
  }

  Widget buildItemCard(int index) {
    var transaction = _transactions[index];
    var cardGlobalKey = GlobalKey();

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
      buySellNumberTextField("买入数量", buyNumber, (number) => buyNumber = number),
      buySellTextField("买入价格", buyPrice, (price) => buyPrice = price),
      // buildTimePicker(context, "买入时间", buyDate, (date) => buyDate = date),
    ];

    if (transaction.sell != null) {
      columnChildren.add(buySellNumberTextField(
          "卖出数量", sellNumber, (number) => sellNumber = number));
      columnChildren.add(
          buySellTextField("卖出价格", sellPrice, (price) => sellPrice = price));
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
    return _textFieldBuilder(
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
        )
    );

  }

  Widget buySellNumberTextField(String title, int number, Function onChange) {
    return _textFieldBuilder(
        title,
        TextField(
          keyboardType: TextInputType.number,
          controller: TextEditingController()..text = number.toString(),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10)
          ],
          onChanged: (str) {
            onChange(int.parse(str));
          },
        ));
  }

  Widget buySellTextField(String title, num price, Function onChange) {
    return _textFieldBuilder(
        title,
        TextField(
          keyboardType: TextInputType.number,
          controller: TextEditingController()..text = price.toString(),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
            LengthLimitingTextInputFormatter(10)
          ],
          onChanged: (str) {
            onChange(num.parse(str));
          },
        ));
  }

  Widget _textFieldBuilder(String title, Widget valueChild) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Text(
            title + ":\t",
            style: TextStyle(fontSize: 15),
          ),
        ),
        Expanded(child: valueChild)
      ],
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
            maxLines: 1, style: TextStyle(color: color, fontSize: 14)),
      ),
    );
  }

  Expanded buildKeyValuePair(String title, Object value,
      {Color color = color2,
      fractionDigits = 2,
      titleSize = 12.0,
      valueSize = 13.0}) {
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


class MyAddTradeFloat extends StatefulWidget {
  @override
  _MyAddTradeFloatState createState() => _MyAddTradeFloatState();
}

class _MyAddTradeFloatState extends State<MyAddTradeFloat> {
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(fontSize: 16);
    return SpeedDial(
      marginRight: 25,//右边距
      marginBottom: 50,//下边距
      animatedIcon: AnimatedIcons.menu_close,//带动画的按钮
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: true,//是否显示按钮
      closeManually: false,//是否在点击子按钮后关闭展开项
      curve: Curves.bounceIn,//展开动画曲线
      overlayColor: Colors.black,//遮罩层颜色
      overlayOpacity: 0.5,//遮罩层透明度
      onOpen: () => print('OPENING DIAL'),//展开回调
      onClose: () => print('DIAL CLOSED'),//关闭回调
      tooltip: 'Speed Dial',//长按提示文字
      heroTag: 'speed-dial-hero-tag',//hero标记
      backgroundColor: Colors.blue,//按钮背景色
      foregroundColor: Colors.white,//按钮前景色/文字色
      elevation: 8.0,//阴影
      shape: CircleBorder(),//shape修饰
      children: [//子按钮
        SpeedDialChild(
            child: Icon(Icons.accessibility),
            backgroundColor: Colors.red,
            label: '快速卖出',
            labelStyle: textStyle,
            onTap: (){
              // onButtonClick(1);
            }
        ),
        SpeedDialChild(
          child: Icon(Icons.brush),
          backgroundColor: Colors.orange,
          label: '快速买入',
          labelStyle: textStyle,
          onTap: (){
            // onButtonClick(2);
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.keyboard_voice),
          backgroundColor: Colors.green,
          label: '第三个按钮',
          labelStyle: textStyle,
          onTap: (){
            _showMyDialog(context);
            // onButtonClick(3);
          },
        ),
      ],
    );

  }

  Future<void> _showMyDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) => AlertDialog(title: Text("sss"),),
    );
  }

}