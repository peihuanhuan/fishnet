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

class NewTransaction extends StatefulWidget {
  Variety _variety;
  bool _buy;
  num _currentPrice;

  num _selectId;


  NewTransaction(this._variety, this._currentPrice, this._buy, [this._selectId]);

  @override
  _NewTransactionState createState() {
    var shouldOperator = _variety.quickOperate(_buy, _currentPrice);

    if (_selectId != null && !_buy) {
      // 只有卖的时候才会指定 id
      return _NewTransactionState(_variety, shouldOperator, _selectId);
    } else {
      return _NewTransactionState(_variety, shouldOperator);
    }
  }
}

class _NewTransactionState extends State<NewTransaction> {
  num _price;
  num _number;
  num _selectedLevel;
  DateTime _date = DateTime.now();
  Operator _selectedOperator;
  Operator _shouldOperator;
  Variety _variety;

  _NewTransactionState(this._variety, this._shouldOperator, [selectedId]) {
    if (selectedId == null) {
      _selectedOperator = _shouldOperator;
    } else {
      var sellOperateWithId = _variety.sellOperateWithId(selectedId);
      _selectedOperator = sellOperateWithId;
    }
    _selectedLevel = _selectedOperator.priceNumberPair?.level;


    // 可能失败，在 build 里面做的
    _price = _selectedOperator.priceNumberPair?.price;
    _number = _selectedOperator.priceNumberPair?.number;
  }

  @override
  Widget build(BuildContext context) {
    if (!_selectedOperator.isSuccess()) {
      toast(_selectedOperator.failMessage);
      Navigator.pop(context);
      return Container();
    }

    PriceNumberPair priceNumber = _shouldOperator.priceNumberPair;

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
          widget._buy ? '买入' : "卖出",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<double>(
              value: _selectedLevel.toDouble(),
              items: widget._buy ? buyItems() : sellItems(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value;
                  if (widget._buy) {
                    _selectedOperator = widget._variety.buyOperateWithLevel(_selectedLevel);
                  } else {
                    _selectedOperator = widget._variety.sellOperateWithLevel(_selectedLevel);
                  }
                  _price = _selectedOperator.priceNumberPair.price;
                  _number = _selectedOperator.priceNumberPair.number;
                });
              },
              decoration: InputDecoration(
                filled: true,
                prefixText: "幅度 ",
                labelText: "幅度 ",
                labelStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                prefixStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                fillColor: Colors.white,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: UnderlineInputBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    borderSide: BorderSide.none),
              ),
            ),
            buildDiv(),

            buildPriceField((value) {
              setStateIfNeed(_price, value);
              _price = value;
            }, defaultValue: getControllerText(_price), ),
            buildDiv(),

            buildNumberField((value) {
              setStateIfNeed(_number, value);
              _number = value;
            }, defaultValue: getControllerText(_number)),
            buildDiv(),

            buildDateField(context, _date, (value) {
              setState(() {
                _date = value;
              });
            }, firstDate: _selectedOperator.buyDate),

            Padding(
              padding: const EdgeInsets.only(top: 3.0, bottom: 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedOperator.extraMessage ?? "",
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                      Offstage(
                        // 是否显示
                        offstage: !((!_shouldOperator.isSuccess() ||
                                _selectedOperator.priceNumberPair.level != _shouldOperator.priceNumberPair.level) &&
                            widget._currentPrice != 0),
                        child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "现价和幅度不太匹配。",
                              style: TextStyle(color: Colors.deepOrange),
                            )),
                      ),
                    ],
                  ),
                  Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "总金额 ￥${(_number * _price).toStringAsFixed(2)}",
                        style: TextStyle(color: activeCardColor.mediumEmphasisColor),
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
              child: MaterialButton(
                onPressed: !checkEnable() ? null : (){
                  if (widget._buy) {
                    Trade buy = Trade(id(), _price, _number, _date);
                    var twoDirectionTransactions =
                        TwoDirectionTransactions(id(), _selectedOperator.priceNumberPair.level, buy, null);
                    widget._variety.transactions.add(twoDirectionTransactions);
                    saveVariety(widget._variety);
                  } else {
                    List<TwoDirectionTransactions> ts = [];
                    ts.addAll(widget._variety.transactions);
                    ts.sort((a, b) => b.buy.time.microsecond.compareTo(a.buy.time.microsecond));
                    for (var transaction in ts) {
                      if (transaction.level == priceNumber.level && transaction.sell == null) {
                        if (_number > transaction.buy.number) {
                          toast("最多卖 ${transaction.buy.number} 份。");
                          return false;
                        }
                        transaction.sell = Trade(id(), _price, _number, DateTime.now());
                        break;
                      }
                    }
                    saveVariety(widget._variety);
                  }

                  Navigator.pop(context);
                },
                minWidth: double.infinity,
                height: 45,
                color: Color(0xff279EF8),
                disabledColor: Color(0xFFC8DFF3),
                textColor: Colors.white,
                child: Text("确认操作"),
                shape:
                    RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(50))),
              ),
            )
          ],
        ),
      ),
    );
  }

  String getControllerText(num defaultValue) => defaultValue == -1 ? "" :  (defaultValue == 0 ? "0" : defaultValue.toString());

  bool checkEnable() {
      return _number > 0 && _price > 0;
  }

  void setStateIfNeed(num a, num b) {
    if(a == b) {
      return;
    }
    if (a * b <= 0) {
      // 边沿触发
      setState(() {});
    }
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
