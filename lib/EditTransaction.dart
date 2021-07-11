import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:fishnet/util/PrecisionLimitFormatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'domain/dto/Operator.dart';
import 'domain/dto/PriceNumberPair.dart';
import 'domain/entity/Variety.dart';

class EditTransaction extends StatefulWidget {
  Operator _operator;
  Variety _variety;

  EditTransaction(this._variety, this._operator);

  @override
  _EditTransactionState createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  num _price;
  num _number;

  @override
  Widget build(BuildContext context) {
    var operator = widget._operator;
    _price = operator.priceNumberPair.price;
    _number = operator.priceNumberPair.number;

    PriceNumberPair priceNumber = operator.priceNumberPair;

    return new Scaffold(
      appBar: new AppBar(
        elevation: 0,
        // 隐藏阴影
        backgroundColor: activeCardColor.bgColor,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(
          color: Colors.black87, //修改颜色
        ),
        // foregroundColor: Colors.black,
        title: new Text(
          '买入',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
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
            DropdownButtonFormField<double>(
              value: operator.priceNumberPair.level.toDouble(),
              // isExpanded: true,
              items: items(),
              onChanged: (value) {
                setState(() {
                  // _mesh = value / 100;
                });
              },
              decoration: InputDecoration(
                filled: true,
                prefixText: "幅度",
                labelText: "幅度",
                fillColor: Colors.white,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                prefixStyle: TextStyle(fontSize: 14),
                labelStyle: TextStyle(fontSize: 14),
                border: UnderlineInputBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    borderSide: BorderSide.none),
              ),
            ),
            Container(
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 12.0, right: 12.0),
                  color: Colors.grey,
                  height: 0.5,
                )),
            TextField(
              textAlign: TextAlign.right,
              inputFormatters: <TextInputFormatter>[
                PrecisionLimitFormatter(3),
                LengthLimitingTextInputFormatter(8),
                FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
              ],
              controller: (TextEditingController()..text = _price.toStringAsFixed(3)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixText: "价格",
                labelText: "价格",
                prefixStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                labelStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: UnderlineInputBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(0)),
                    borderSide: BorderSide.none),
              ),
            ),
            Container(
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 12.0, right: 12.0),
                  color: Colors.grey,
                  height: 0.5,
                )),
            TextField(
                textAlign: TextAlign.right,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                ],
                controller: (TextEditingController()..text = _number.toStringAsFixed(3)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixText: "数量",
                  labelText: "数量",
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                  prefixStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                  hintText: "输入100的倍数",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                      borderSide: BorderSide.none),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 3.0, bottom: 8),
              child: Row(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        operator.extraMessage ?? "",
                        style: TextStyle(color: activeCardColor.mediumEmphasisColor),
                      )),
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
                // C8DFF3  disabled
                onPressed: () {},
                minWidth: double.infinity,
                color: Color(0xff279EF8),
                textColor: Colors.white,
                child: Text("确认操作"),
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<double>> items() {
    var mesh = widget._variety.mesh;
    num level = 1.0;

    List<double> items = [];
    while (level > 0) {
      items.add(level);
      level = minusAccurately(level, mesh);
    }

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
