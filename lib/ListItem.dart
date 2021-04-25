import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("aaa");
  }
}


class TableScreen extends StatefulWidget {
  TableScreen({Key key}) : super(key: key);

  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<TableRow> _renderList() {
    List titleList = ['aaaaaaaa', 'bbbb', 'ccccccccc', 'ddd', 'ee'];
    List<TableRow> list = [];
    for (var i = 0; i < titleList.length; i++) {
      list.add(
          TableRow(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Text(titleList[i]),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Text(i % 2 == 0 ? 'content' : 'contentcontentcontentcontentcontentcontentcontentcontent'),
                )
              ]
          )
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 40),
        color: Colors.black12,
        child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth()
            },
            children: _renderList()
        ),
      ),
    );
  }
}