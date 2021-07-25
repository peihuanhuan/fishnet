import 'dart:io';
import 'dart:math';

import 'package:fishnet/colors/CardColorImpl2.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:fishnet/widgets/AddVarietyFloat.dart';
import 'package:fishnet/widgets/DeleteVarietyDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fishnet/MyCardItem.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'GridTransactionList.dart';
import 'SortVarietyList.dart';
import 'colors/CardColor.dart';
import 'colors/CardColorImpl1.dart';
import 'domain/entity/FoundPrice.dart';
import 'domain/entity/Variety.dart';
import 'persistences/PersistenceLayer.dart';



void main() {
  runApp(new VarietyCardList());
}

class VarietyCardList extends StatefulWidget {
  @override
  _VarietyCardListState createState() => new _VarietyCardListState();
}

num totalAmount = 0;
var foundPriceMap = Map<String, FoundPrice>();

class _VarietyCardListState extends State<VarietyCardList> {
  final GlobalKey<AnimatedListState> _listKey = new GlobalKey<AnimatedListState>();
  ListModel<Variety> _list;

  @override
  void initState() {
    update();
  }

  Future update() async {
    if (_list == null) {
      _list = new ListModel<Variety>(
        listKey: _listKey,
        initialItems: [],
        removedItemBuilder: _buildRemovedItem,
      );
    }

    var initialItems = await getVarieties();

    // initialItems.addAll(defaultVarieties);
    _list = new ListModel<Variety>(
      listKey: _listKey,
      initialItems: initialItems,
      removedItemBuilder: _buildRemovedItem,
    );
    setState(() {});
    calcTotalAmount();
  }

  void calcTotalAmount() async {
    var foundPrices = await queryPrice(_list._items.map((e) => e.code).toList());

    foundPrices.forEach((foundPrice) {
      foundPriceMap[foundPrice.code] = foundPrice;
    });

    totalAmount = 0;
    _list._items.forEach((variety) {
      totalAmount += variety.holdingAmount(foundPriceMap[variety.code].price);
    });

    print('total amount  ============ $totalAmount');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: activeCardColor.bgColor,
      ),
      home: new Scaffold(
        floatingActionButton: AddVarietyFloat(
            (_code, _mesh, _firstPrice, _firstNumber, _tag) => _insert(_code, _mesh, _firstPrice, _firstNumber, _tag),
            (_code, _mesh, _firstPrice, _firstNumber) {
          return _code.toString().length == 6 &&
              _firstPrice != null &&
              _firstPrice > 0 &&
              _firstNumber != null &&
              _firstNumber > 100;
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SafeArea( // 自动处理刘海屏
          child: RefreshIndicator(
            onRefresh: () async {
              update();
            },
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      key: _listKey,
                      itemCount: max(_list.length, 1) + 1,
                      itemBuilder: _buildItem,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      ),
      localizationsDelegates: [
        //此处 系统是什么语言就显示什么语言
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        //此处 系统是什么语言就显示什么语言
        const Locale('zh', 'CH'),
        const Locale('en', 'US'),
      ],
    );
  }

  Widget _buildItem(BuildContext context, int index) {

    if(index == 0) {
      return Header(_list._items, foundPriceMap, (){setState(() {
      });});
    }

    if(index == 1 && _list.length == 0) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: Text("不来一个？", style: TextStyle(fontSize: 13, color: activeCardColor.lowEmphasisColor),)),
      );
    }

    index--;
    var item = _list[index];
    return new CardItem(
      item: item,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GridTransactionList(item.id, foundPriceMap[item.code] == null ? 0: foundPriceMap[item.code].price);
        })).then((value) {
          update();
        });
      },

      edit: (name, tag) {
        setState(() {
          item.name = name;
          item.tag = tag;
          saveVariety(item);
        });
      },
      remove: () {
        setState(() {
          var needDelete = item;
          _list.removeAt(index);
          deleteVariety(needDelete.id);
          toast("删除成功");
        });
      },

    );
  }




  Widget _buildRemovedItem(Variety item, BuildContext context, Animation<double> animation) {
    return new CardItem(
      // animation: animation,
      item: item,
    );
  }

// Insert the "next item" into the list model.
  Future<void> _insert(code, mesh, firstPrice, firstNumber, tag) async {
    var name = await queryName(code.toString());

    print('插入啦 $code $name');

    var variety = Variety(id(), code, name, mesh, firstPrice, firstNumber, tag, [], DateTime.now());
    _list.insert(0, variety);
    saveVariety(variety);
    setState(() {});
  }

  void _remove(Variety variety) {
    _list.removeAt(_list.indexOf(variety));
    setState(() {});
  }
}

class ListModel<E> {
  ListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = new List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  // AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    // _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    // if (removedItem != null) {
    //   _animatedList.removeItem(index,
    //       (BuildContext context, Animation<double> animation) {
    //     return removedItemBuilder(removedItem, context, animation);
    //   });
    // }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}


class Header extends StatefulWidget {

  List<Variety> _varieties;
  Map<String, FoundPrice> _foundPriceMap;

  Function _updateState;

  Header(this._varieties, this._foundPriceMap, this._updateState);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {



    var totalAmount = widget._varieties.map((e) => e.holdingAmount(widget._foundPriceMap[e.code] == null ? 0 : widget._foundPriceMap[e.code].price))
        .fold(0, (curr, next) => curr + next);

    var totalCost = widget._varieties.map((e) => e.totalCost())
        .fold(0, (curr, next) => curr + next);

    var totalProfit = widget._varieties.map((e) => e.totalProfit(widget._foundPriceMap[e.code] == null ? 0 : widget._foundPriceMap[e.code].price))
        .fold(0, (curr, next) => curr + next);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(3,12,0,6),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text("账户总览", style: TextStyle(fontSize: 18), textAlign: TextAlign.start,)),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          color: activeCardColor.flatBgColor,
          child: Row(
            children: [
              Expanded(
                child: Column(
                children: [
                  buildFlex([buildKeyValuePair("总资产（元）", totalAmount.toStringAsFixed(2), titleSize: 16.0, valueSize: 22.0, titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.highEmphasisColor),]),
                  buildFlex([
                    buildKeyValuePair("净投入（元）", totalCost.toStringAsFixed(2), titleColor: activeCardColor.mediumEmphasisColor, valueColor: activeCardColor.highEmphasisColor),
                    buildKeyValuePair("累计收益（元）", totalProfit.toStringAsFixed(2), titleColor: activeCardColor.mediumEmphasisColor, valueColor: getMoneyColor(totalProfit, activeCardColor))
                  ]),
                ],
        ),
              ),
            ],
          ),),
        Padding(
          padding: const EdgeInsets.fromLTRB(3,12,0,0),
          child: Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                  child: Text("我的品种", style: TextStyle(fontSize: 18, ), textAlign: TextAlign.start, )),
              Flexible(fit: FlexFit.tight, child: SizedBox()),

              IconButton(onPressed: (){

                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SortVarietyList(widget._varieties);
                })).then((value) {
                  widget._updateState();
                });


              }, icon: Icon(Icons.menu))
            ],
          ),
        )
      ],
    );

  }


  Flex buildFlex(List<Expanded> expandeds) {
    return Flex(
      direction: Axis.horizontal,
      children: expandeds,
    );
  }
}


class CardItem extends StatelessWidget {
  const CardItem({
    Key key,
    this.remove,
    this.edit,
    this.onTap,
    @required this.item,
  }) : super(key: key);

  final Function remove;
  final Function edit;
  final VoidCallback onTap;
  final Variety item;

  @override
  Widget build(BuildContext context) {
    return StatefulFoundCardItem(item, totalAmount, foundPriceMap[item.code], key, remove, edit, onTap);
  }
}


