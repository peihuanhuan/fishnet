import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/material.dart';

import '../NewVariety.dart';

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
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return NewVariety(widget._insert);
          })).then((value) {
            setState(() {});
          });
          // return _showMyDialog(context);
        },
        backgroundColor: Color(0xFFFFD103));
  }

}
