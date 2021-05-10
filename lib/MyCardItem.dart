import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'GridTransactionList.dart';
import 'beans.dart';

class MyCardItem extends StatelessWidget {

  static const double _left = 22;

  Variety variety;


  MyCardItem(this.variety);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push( context,
          MaterialPageRoute(builder: (context) {
            return GridTransactionList();
          }));
        },
      child: Card(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(_left, 10, 8, 6),
                      child: new Text(variety.name, style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: new Text('占比', style: TextStyle(color: color1, fontSize: 10)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: new Text(toPercentage(0.1), style: TextStyle(color: color2, fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              buildPadding(),
              buildFlex([
                buildKeyValuePair("持有金额", variety.holdingAmount()),
                buildKeyValuePair("资金年化率", toPercentage(variety.annualizedRate()))
              ]),
              buildFlex([
                buildKeyValuePair("实盈", variety.realProfit(), color: color3),
                buildKeyValuePair("波段次数", variety.twoWayFrequency())
              ]),
              buildFlex([
                buildKeyValuePair("浮盈", variety.floatingProfit(), color: color4),
              ]),
              buildPadding(),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(_left, 10, 8, 6),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                      child: new Text('总收益   ', style: TextStyle(color: color2, fontSize: 12),),
                    ),
                    new Text(variety.totalProfit().toString(), style: TextStyle(color: color3, fontSize: 16),),
                  ],),
                ),
              ),
            ],
          )),
    );

  }







  Padding buildPadding() {
    return Padding(
          padding: const EdgeInsets.fromLTRB(_left, 0, 8, 0),
          child: Divider(height: 0.5,color: Color(0xFFABAA9A)),
        );
  }

  Flex buildFlex(List<Expanded> expandeds) {
    return Flex(
          direction: Axis.horizontal,
          children: expandeds,
        );
  }



}