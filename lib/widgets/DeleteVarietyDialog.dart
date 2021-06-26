import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/material.dart';

class DeleteVarietyDialog extends StatefulWidget {
  Function _okFunction;
  Function _checkOkButtonEnable;
  String _hintTitle;

  DeleteVarietyDialog(this._hintTitle, this._okFunction, this._checkOkButtonEnable);

  @override
  _DeleteVarietyDialogStatefulWidget createState() => _DeleteVarietyDialogStatefulWidget();
}

class _DeleteVarietyDialogStatefulWidget extends State<DeleteVarietyDialog> {
  num _code;
  bool enable = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("删除网格"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          numberFieldInputWidget("代码", (value) {
            _code = value;
            checkClickable();
          }, hintText: widget._hintTitle),
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
              ],
            ),
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
      widget._okFunction(_code.toString());
      Navigator.of(context).pop();
    };
  }
}
