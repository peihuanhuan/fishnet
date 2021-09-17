import 'dart:collection';

import 'package:fishnet/persistences/PersistenceLayer.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:fishnet/util/PrecisionLimitFormatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'domain/dto/Operator.dart';
import 'domain/dto/PriceNumberPair.dart';
import 'domain/entity/Trade.dart';
import 'domain/entity/TwoDirectionTransactions.dart';
import 'domain/entity/Variety.dart';

class EditTransaction extends StatefulWidget {
  Variety _variety;
  TwoDirectionTransactions _transactions;

  EditTransaction(this._variety, this._transactions);

  @override
  _EditTransactionState createState() {
    return _EditTransactionState(_transactions);
  }
}

class _EditTransactionState extends State<EditTransaction> {
  TwoDirectionTransactions _transactions;

  num _buyPrice;
  num _buyNumber;
  DateTime _buyDate;

  num _sellPrice;
  num _sellNumber;
  DateTime _sellDate;

  _EditTransactionState(this._transactions) {
    _buyPrice = _transactions.buy.price;
    _buyNumber = _transactions.buy.number;
    _buyDate = _transactions.buy.time;

    _sellPrice = _transactions.sell?.price;
    _sellNumber = _transactions.sell?.number;
    _sellDate = _transactions.sell?.time;
  }

  bool enable;

  @override
  Widget build(BuildContext context) {
    var children = [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          "买入",
          style: TextStyle(fontSize: 18),
        ),
      ),
      buildPriceField((value) {
        setStateIfNeed(_buyPrice, value);
        _buyPrice = value;
      }, isTop: true, defaultValue: getControllerText(_buyPrice)),
      buildDiv(),
      buildNumberField(
        (value) {
          setStateIfNeed(_buyNumber, value);
          _buyNumber = value;
        },
        defaultValue: getControllerText(_buyNumber),
      ),
      buildDiv(),
      buildDateField(context, _buyDate, (value) {
        setState(() {
          _buyDate = value;
        });
      }),
    ];

    if (_transactions.sell != null) {
      var sellChildren = [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 32),
          child: Text(
            "卖出",
            style: TextStyle(fontSize: 18),
          ),
        ),
        buildPriceField((value) {
          setStateIfNeed(_sellPrice, value);
          _sellPrice = value;
        }, isTop: true, defaultValue: getControllerText(_sellPrice)),
        buildDiv(),
        // todo 做下  卖的不能比买的多的校验
        buildNumberField((value) {
          setStateIfNeed(_sellNumber, value);
          _sellNumber = value;
        }, defaultValue: getControllerText(_sellNumber)),
        buildDiv(),
        buildDateField(context, _sellDate, (value) {
          setState(() {
            _sellDate = value;
          });
        }),
      ];

      children.addAll(sellChildren);
    }

    children.add(Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
      child: MaterialButton(
        onPressed: !checkEnable()
            ? null
            : () {
                if (_transactions.sell != null) {
                  if(_sellNumber > _buyNumber) {
                    toast("卖出数量不能大于买入数量");
                    return;
                  }
                  if(_sellDate.millisecondsSinceEpoch < _buyDate.millisecondsSinceEpoch) {
                    toast("卖出时间不能早于买入时间");
                    return;
                  }
                }

                _transactions.buy.price = _buyPrice;
                _transactions.buy.number = _buyNumber;
                _transactions.buy.time = _buyDate;

                if (_transactions.sell != null) {
                  _transactions.sell.price = _sellPrice;
                  _transactions.sell.number = _sellNumber;
                  _transactions.sell.time = _sellDate;
                }
                saveVariety(widget._variety);
                Navigator.pop(context);
              },
        minWidth: double.infinity,
        height: 45,
        color: Color(0xff279EF8),
        disabledColor: Color(0xFFC8DFF3),
        textColor: Colors.white,
        child: Text("确认操作"),
        shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(50))),
      ),
    ));
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        elevation: 0,
        // 隐藏阴影
        backgroundColor: activeCardColor.bgColor,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(
          color: Colors.black87, //修改颜色
        ),
        // foregroundColor: Colors.black,
        title: new Text(
          "编辑",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  bool checkEnable() {
    if (_transactions.sell == null) {
      return _buyNumber > 0 && _buyPrice > 0;
    } else {
      return _buyNumber > 0 &&
          _buyPrice > 0 &&
          _sellNumber > 0 &&
          _sellPrice > 0;
    }
  }

  String getControllerText(num defaultValue) => defaultValue == -1
      ? ""
      : (defaultValue == 0 ? "0" : defaultValue.toString());

  void setStateIfNeed(num a, num b) {
    if (a == b) {
      return;
    }
    if (a * b <= 0) {
      // 边沿触发
      setState(() {});
    }
  }

  Container buildDiv() {
    return Container(
        color: Colors.white,
        child: Container(
          margin: EdgeInsets.only(left: 12.0, right: 12.0),
          color: activeCardColor.lowEmphasisColor,
          height: 0.2,
        ));
  }

  List<DropdownMenuItem<double>> sellItems() {
    Set<double> items = HashSet();

    widget._variety.transactions.forEach((element) {
      if (element.sell == null) {
        items.add(element.level.toDouble());
      }
    });

    var list = items.toList();
    list.sort((a, b) => b.compareTo(a));
    return itemsMapToText(list);
  }

  List<DropdownMenuItem<double>> buyItems() {
    var mesh = widget._variety.mesh;
    num level = 1.0;

    List<double> items = [];
    while (level > 0) {
      items.add(level);
      level = minusAccurately(level, mesh);
    }

    return itemsMapToText(items);
  }

  List<DropdownMenuItem<double>> itemsMapToText(List<double> items) {
    return items
        .map((e) => DropdownMenuItem(
            value: e,
            child: Text(
              '$e',
              style: TextStyle(fontSize: 14),
            )))
        .toList();
  }
}
