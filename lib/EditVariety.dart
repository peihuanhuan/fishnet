import 'package:fishnet/domain/entity/Variety.dart';
import 'package:fishnet/persistences/PersistenceLayer.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditVariety extends StatefulWidget {

  Variety _variety;
  EditVariety(this._variety, {Key key}) : super(key: key);

  @override
  _EditVarietyState createState() => _EditVarietyState();
}

class _EditVarietyState extends State<EditVariety> {




  @override
  Widget build(BuildContext context) {
    String _name = widget._variety.name;
    String _tag = widget._variety.tag;


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
        title: new Text("修改", style: TextStyle(color: Colors.black87)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            buildStringField(() {}, title: "基金代码", isTop: true, readOnly: true, defaultValue: widget._variety.code),
            buildDiv(),


            DropdownButtonFormField<int>(
              value: (widget._variety.mesh * 100).toInt(),
              items: items(),
              onChanged: null,
              decoration: InputDecoration(
                filled: true,
                prefixText: "幅度 ",
                labelText: "幅度 ",
                labelStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                prefixStyle: TextStyle(color: activeCardColor.mediumEmphasisColor, fontSize: 12),
                fillColor: Colors.white54,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: UnderlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            buildDiv(),

            buildPriceField((value) {}, title: "第一网价格", readOnly: true, defaultValue: widget._variety.firstPrice.toString()),
            buildDiv(),

            buildNumberField(() {}, title: "第一网数量", readOnly: true, defaultValue: widget._variety.firstNumber.toString()),
            buildDiv(),

            buildStringField((value) {
              _name = value;
            }, title: "名称", defaultValue: widget._variety.name == "-" ? "" : widget._variety.name, autofocus: true),

            buildStringField((value) {
              _tag = value;
            }, title: "备注（可选）", defaultValue: _tag),
            buildDiv(),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
              child: MaterialButton(
                onPressed: (){


                  widget._variety.name = _name;
                  widget._variety.tag = _tag;
                  saveVariety(widget._variety);

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


  List<DropdownMenuItem<int>> items() {
    var items = [3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 30];
    return items.map((e) => DropdownMenuItem(value: e, child: Text(' $e%'))).toList();
  }


}
