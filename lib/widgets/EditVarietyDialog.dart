import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/material.dart';

class EditVarietyDialog extends StatefulWidget {


  String _defaultName;
  String _defaultTag;

  Function _okFunction;


  EditVarietyDialog(this._defaultName, this._defaultTag, this._okFunction);

  @override
  _EditVarietyDialogStatefulWidget createState() => _EditVarietyDialogStatefulWidget();
}

class _EditVarietyDialogStatefulWidget extends State<EditVarietyDialog> {
  String _name;
  String _tag;

  bool enable = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("修改信息"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          stringFieldInputWidget("名称", (value) {
            _name = value;
          }, defaultValue: widget._defaultName),
          stringFieldInputWidget("标签", (value) {
            _tag = value;
          }, defaultValue: widget._defaultTag, hintText: "无"),
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


  Function onOkPressed(BuildContext context) {
    return () async {
      widget._okFunction(_name, _tag);
      Navigator.of(context).pop();
    };
  }
}
