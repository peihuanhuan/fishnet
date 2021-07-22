import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/material.dart';

class DeleteVarietyDialog extends StatefulWidget {
  Function _checkOkButtonEnable;
  Function _okFunction;
  String _hintTitle;

  DeleteVarietyDialog(this._hintTitle, this._checkOkButtonEnable, this._okFunction);

  @override
  _DeleteVarietyDialogStatefulWidget createState() => _DeleteVarietyDialogStatefulWidget();
}

class _DeleteVarietyDialogStatefulWidget extends State<DeleteVarietyDialog> {
  num _code;
  bool enable = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("删除品种"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          numberFieldInputWidget("代码", (value) {
            _code = value;
            checkClickable();
          }, hintText: widget._hintTitle, helperText: "需要输入代码以确认删除"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
            child: Text('确认'),
            onPressed: onOkPressed(context)),
      ],
    );
  }

  void checkClickable() {
    setState(() {
      enable = widget._checkOkButtonEnable(_code.toString());
    });
  }

  Function onOkPressed(BuildContext context) {
    if (!enable) {
      return null;
    }
    return () async {
      widget._okFunction();
      Navigator.of(context).pop();
    };
  }
}
