import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'MyCardItem.dart';
import 'beans.dart';





class GridTransactionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GridTransactionListState();
  }
}

Color c1 = Color(0xFFFEF1FA);
Color c2 = Color(0xFFEBF6FF);
Color c3 = Color(0xFFFAF2FE);
Color c4 = Color(0xFFFBF4E5);

List<Color> cc = [c1, c2, c3, c4];

class GridTransactionListState extends State<GridTransactionList> {
  var _words = <GridTwoDirectionTransactions>[];

  @override
  void initState() {
    super.initState();
    _retrieveData();
  }

  void _retrieveData() {
    Future.delayed(Duration(seconds: 0)).then((e) {
      setState(() {
        //重新构建列表
        _words.add(GridTwoDirectionTransactions());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _words.length,
            itemBuilder: (context, index) {
              //如果到了表尾
              //不足100条，继续获取数据
              if (_words.length - 1 < 2) {
                _retrieveData();
              }
              //显示单词列表项
              return buildFlex(index);
            },
            // separatorBuilder: (context, index) => Divider(height: .0),
          ),
        )
      ],
    );
  }

  Widget buildFlex(int index) {
    var flex = 8;
    Widget card =  Card(
      color: cc[index % 4],
      child:MediaQuery.removePadding(context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: ExpansionTile(
            tilePadding: EdgeInsets.all(0),
            childrenPadding: EdgeInsets.all(0),
            trailing: Container(height:0.0,width:0.0), // 覆盖默认的
            title: Flex(
              direction: Axis.horizontal,
              children: [
                buildNoTitleExpanded("0.$index"),
                buildExpanded2(flex, "买入", index, 10000, color: Color(0xFF101A2B)),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("￥90100"),
                  ),
                ),
              ],
            ),
            // trailing: SizedBox(),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    buildNoTitleExpanded(null),
                    buildExpanded2(flex, "卖出", 112, 100, color: Color(0xFF101A2B)),
                    Icon(Icons.edit),
                    Icon(Icons.delete),
                  ],
                ),
              ),
            ],
          ), ),


    );

    return card;
  }

  static const Color color1 = Color(0xAAA3A1A8);

  Expanded buildExpanded2(int flex, String title, num price, int count,
      {Color color = MyCardItem.color2}) {
    return  Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(color: color1, fontSize: 8),
                textAlign: TextAlign.left,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: new Text("$price * $count = ￥${price * count}",
                    style: TextStyle(color: color, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildNoTitleExpanded(Object value,
      {Color color = MyCardItem.color2}) {
    if (value == null) {
      return Expanded(
        flex: 1,
        child: Text(""),
      );
    }
    return Expanded(
        flex: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFD5F3F4), Color(0xFFD7FFF0)]), //背景渐变
              shape: BoxShape.circle,
              // boxShadow: [
              //   //阴影
              //   BoxShadow(
              //       color: Colors.black54,
              //       offset: Offset(1.0, 1.0),
              //       blurRadius: 2.0)
              // ]
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            child: AutoSizeText(value.toString(),
                maxLines: 1, style: TextStyle(color: color, fontSize: 18)),
          ),
        ));
  }
}
