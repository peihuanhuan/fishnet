import 'package:flutter/material.dart';

import 'CustomExpansionPanelList.dart';
main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        home: ExpansionParnelListDemo()
    );
  }
}

class ExpansionParnelListDemo extends StatefulWidget {
  ExpansionParnelListDemo({Key key}) : super(key: key);

  _ExpansionParnelListDemoState createState() => _ExpansionParnelListDemoState();
}

class _ExpansionParnelListDemoState extends State<ExpansionParnelListDemo> {

  List<int> mList;
  // 存放状态和索引List
  List<ExpandStateBean> expandStateList;

  _ExpansionParnelListDemoState(){
    mList = new List();
    expandStateList = new List();
    for(int i = 0; i < 10; i ++){
      mList.add(i);
      // 第一个是索引，第二个是否打开;
      expandStateList.add(ExpandStateBean(i,false));
    }
  }

  // 判断用户点击是否打开
  _setCurrentIndex(int index, isExpand){
    setState(() {
      // 循环判断用户点击和索引是否一致，并操作状态
      expandStateList.forEach((item){
        if(item.index == index){
          item.isOpen = !isExpand;
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expansion List')),
      // 可滚动的控件
      body: SingleChildScrollView(
        // ExpansionPanelList 必须放在可滚动的控件里面
        child: ExpansionPanelList(
          expansionCallback: (index,bol){
            _setCurrentIndex(index,bol);
          },
          children: mList.map((index){
            return ExpansionPanel(
              // 上下文 是否是打开的
                headerBuilder: (context,isExpanded){
                  return ListTile(
                    title: Text('我是标题.$index'),
                  );
                },
                canTapOnHeader: true,
                body: Card(
                  child: Text('内容.$index'),
                ),
                // 判断是否打开
                isExpanded: expandStateList[index].isOpen
            );
          }).toList(),
        ),
      ),
    );
  }
}

// 控制打开和关闭的类
class ExpandStateBean{
  var isOpen;
  var index;
  ExpandStateBean(this.index,this.isOpen);
}