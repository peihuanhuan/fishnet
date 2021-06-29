import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/material.dart';

class AddVarietyFloat extends StatefulWidget {
  Function _insert;
  Function _checkOkButtonEnable;

  AddVarietyFloat(this._insert, this._checkOkButtonEnable);

  @override
  _AddVarietyFloatState createState() => _AddVarietyFloatState();
}

class _AddVarietyFloatState extends State<AddVarietyFloat> {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
        child: Icon(Icons.add, color: Colors.black, size: 40),
        onPressed: () => _showMyDialog(context),
        backgroundColor: Color(0xFFFFD103));
  }

  Future<void> _showMyDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) => _AddVarietyDialog(widget._insert, widget._checkOkButtonEnable),
    );
  }
}

class _AddVarietyDialog extends StatefulWidget {
  Function _okFunction;
  Function _checkOkButtonEnable;

  _AddVarietyDialog(this._okFunction, this._checkOkButtonEnable);

  @override
  _AddVarietyDialogState createState() => _AddVarietyDialogState();
}

class _AddVarietyDialogState extends State<_AddVarietyDialog> {
  int _loading = 0;
  num _code;
  num _firstNumber;
  num _firstPrice;
  bool enable = false;
  num _mesh = 0.05;
  String _tag = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("新建品种"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          numberFieldInputWidget("代码", (value) {
            _code = value;
            checkClickable();
          }, maxLength: 6),
          customFieldInputWidget(
              "幅度",
              DropdownButton<int>(
                  value: (_mesh * 100).toInt(),
                  isExpanded: true,
                  items: items(),
                  onChanged: (value) {
                    setState(() {
                      _mesh = value / 100;
                    });
                  })),
          numberFieldInputWidget("第一网价格", (value) {
            _firstPrice = value;
            checkClickable();
          }, isPrice: true, limit: 7),
          numberFieldInputWidget("第一网数量", (value) {
            _firstNumber = value;
            checkClickable();
          }),
          stringFieldInputWidget("标签", (value) {
            _tag = value;
          }, defaultValue: _tag, hintText: "可选"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
            child: Row(
              children: [
                Text('确认'),
                Container(height: 15.0 * _loading, width: 15, child: CircularProgressIndicator()),
              ],
            ),
            onPressed: onOkPressed(context)),
      ],
    );
  }

  List<DropdownMenuItem<int>> items() {
    var items = [3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 30];
    return items.map((e) => DropdownMenuItem(value: e, child: Text('$e%'))).toList();
  }

  void checkClickable() {
    setState(() {
      enable = widget._checkOkButtonEnable(_code.toString(), _mesh, _firstPrice, _firstNumber);
    });
  }

  Function onOkPressed(BuildContext context) {
    if (!enable) {
      return null;
    }
    return () async {
      setState(() {
        _loading = 1;
      });
      widget._okFunction(_code.toString(), _mesh, _firstPrice, _firstNumber, _tag);
      setState(() {
        _loading = 0;
      });
      Navigator.of(context).pop();
    };
  }
}
