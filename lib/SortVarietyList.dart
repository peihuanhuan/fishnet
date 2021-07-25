import 'package:fishnet/NewTransaction.dart';
import 'package:fishnet/domain/dto/Operator.dart';
import 'package:fishnet/domain/entity/Trade.dart';
import 'package:fishnet/domain/entity/Variety.dart';
import 'package:fishnet/persistences/PersistenceLayer.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import 'EditTransaction.dart';
import 'colors/CardColor.dart';
import 'colors/CardColorImpl1.dart';
import 'colors/CardColorImpl2.dart';
import 'domain/dto/PriceNumberPair.dart';
import 'domain/entity/TwoDirectionTransactions.dart';

class SortVarietyList extends StatefulWidget {
  List<Variety> _varieties;

  SortVarietyList(this._varieties);

  @override
  _SortVarietyListState createState() => _SortVarietyListState(_varieties);
}

class _SortVarietyListState extends State<SortVarietyList> {
  List<Variety> _varieties;
  List<Widget> children;

  List<Variety> _tmp;

  _SortVarietyListState(this._varieties) {
    children = _varieties.map((variety) => buildCard(variety)).toList();
    _tmp = _varieties;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        elevation: 0,
        // 隐藏阴影
        backgroundColor: activeCardColor.bgColor,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(
          color: Colors.black87, //修改颜色
        ),
        // leading: TextButton(child: Text("完成"),),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("完成"),
          ),
        ],
        // foregroundColor: Colors.black,
        title: new Text("自定义排序", style: TextStyle(color: Colors.black87)),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, bottom: 4),
                child: Text("我的品种", style: TextStyle(fontSize: 12, color: activeCardColor.mediumEmphasisColor), textAlign: TextAlign.start, ),
              ),
              Flexible(fit: FlexFit.tight, child: SizedBox()),

              Padding(
                padding: const EdgeInsets.only(right: 18.0, bottom: 4),
                child: Text("长按拖动排序", style: TextStyle(fontSize: 12, color: activeCardColor.mediumEmphasisColor), textAlign: TextAlign.start, ),
              ),
            ],
          ),
          Expanded(
            child: ReorderableListView(
              proxyDecorator:(Widget child, int index, Animation<double> animation) {
                return child;
              },

              onReorder: (int oldIndex, int newIndex) {

                if (newIndex > oldIndex) {
                  newIndex--;
                }
                final removedWidget = children.removeAt(oldIndex);
                children.insert(newIndex, removedWidget);

                final removed = _tmp.removeAt(oldIndex);
                _tmp.insert(newIndex, removed);

                saveVarieties(_tmp);

              },
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(Variety variety) {
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
          key: UniqueKey(),
          color: activeCardColor.bgColor,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(variety.name.isEmpty ? "-" : variety.name,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: activeCardColor.highEmphasisColor)),
                  Text(variety.code,
                      style: TextStyle(
                          fontSize: 12, color: activeCardColor.highEmphasisColor)),
                ],
              ),
              // Flexible(fit: FlexFit.tight, child: SizedBox()),
              Flexible(fit: FlexFit.tight, child: SizedBox()),
              Icon(Icons.menu)
            ],
          )),
    );
  }
}
