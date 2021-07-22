import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewVariety extends StatefulWidget {

  Function _okFunction;
  NewVariety(this._okFunction, {Key key}) : super(key: key);

  @override
  _NewVarietyState createState() => _NewVarietyState();
}

class _NewVarietyState extends State<NewVariety> {

  int _loading = 0;
  num _code;
  num _firstNumber;
  num _firstPrice;
  bool enable = false;
  num _mesh = 0.05;
  String _tag = "";


  @override
  Widget build(BuildContext context) {


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
        title: new Text("新建",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            buildNumberField((value) {
              setStateIfNeed(_code, value);
              _code = value;
            }, title: "基金代码", isTop: true, hintText: "用于查询名称、净值", maxLength: 6),
            buildDiv(),


            DropdownButtonFormField<int>(
              value: (_mesh * 100).toInt(),
              items: items(),
              onChanged: (value) {
                setState(() {
                  _mesh = value / 100;
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
                    borderSide: BorderSide.none),
              ),
            ),
            buildDiv(),

            buildPriceField((value) {
              setStateIfNeed(_firstPrice, value);
              _firstPrice = value;
            }, title: "第一网价格"),
            buildDiv(),

            buildNumberField((value) {
              setStateIfNeed(_firstNumber, value);
              _firstNumber = value;
            }, title: "第一网数量"),
            buildDiv(),

            buildStringField((value) {
              _tag = value;
            }, title: "备注（可选）"),
            buildDiv(),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
              child: MaterialButton(
                onPressed: !checkEnable() ? null : (){


                  setState(() {
                    _loading = 1;
                  });

                  widget._okFunction(_code.toString(), _mesh, _firstPrice, _firstNumber, _tag);


                  setState(() {
                    _loading = 0;
                  });
                  Navigator.pop(context);
                },
                minWidth: double.infinity,
                height: 45,
                color: Color(0xff279EF8),
                disabledColor: Color(0xFFC8DFF3),
                textColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("确认操作"),
                    Container(height: 15.0 * _loading, width: 15, child: CircularProgressIndicator()),
                  ],
                ),

                shape:
                RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(50))),
              ),
            )
          ],
        ),
      ),
    );
  }

  void setStateIfNeed(num a, num b) {
    // if(a == b) {
    //   return;
    // }
    // if (a * b <= 0) {
      // 边沿触发
      setState(() {});
    // }
  }

  String getControllerText(num defaultValue) => defaultValue == -1 ? "" :  (defaultValue == 0 ? "0" : defaultValue.toString());

  bool checkEnable() {
    return _code.toString().length >= 1 &&
        _firstPrice != null &&
        _firstPrice > 0 &&
        _firstNumber != null &&
        _firstNumber > 0;
  }

  List<DropdownMenuItem<int>> items() {
    var items = [3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 30];
    return items.map((e) => DropdownMenuItem(value: e, child: Text(' $e%'))).toList();
  }


}
