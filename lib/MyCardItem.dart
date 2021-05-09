import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'GridTransactionList.dart';
import 'ListItem.dart';

class MyCardItem extends StatelessWidget {

  num id = 1;
  String title = '华宝油气';
  num fundPercent = 0.1;
  num found = 1000;
  num annualizedRate = 0.1;
  num realProfit = 1000;
  int bandFrequency = 3;
  num floatingProfit = -100;


  static const double _left = 22;


  MyCardItem(this.title, this.fundPercent, this.found, this.annualizedRate,
      this.realProfit, this.bandFrequency, this.floatingProfit);

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
                      child: new Text(title, style: TextStyle(fontSize: 22)),
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
                            child: new Text(toPercent(fundPercent), style: TextStyle(color: color2, fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              buildPadding(),
              buildFlex([
                buildKeyValuePair("持有金额", found),
                buildKeyValuePair("资金年化率", toPercent(annualizedRate))
              ]),
              buildFlex([
                buildKeyValuePair("实盈", realProfit, color: color3),
                buildKeyValuePair("波段次数", bandFrequency)
              ]),
              buildFlex([
                buildKeyValuePair("浮盈", floatingProfit, color: color4),
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
                    new Text((realProfit + floatingProfit).toString(), style: TextStyle(color: color3, fontSize: 16),),
                  ],),
                ),
              ),
            ],
          )),
    );

  }

  String toPercent(num value) => (value * 100).toString() + "%";





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