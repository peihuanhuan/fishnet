import 'dart:io';

import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:fishnet/widgets/AddVarietyFloat.dart';
import 'package:fishnet/widgets/DeleteVarietyDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fishnet/MyCardItem.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'GridTransactionList.dart';
import 'domain/entity/FoundPrice.dart';
import 'domain/entity/Variety.dart';
import 'persistences/PersistenceLayer.dart';

void main() {
  runApp(new AnimatedListSample());
}

class AnimatedListSample extends StatefulWidget {
  @override
  _AnimatedListSampleState createState() => new _AnimatedListSampleState();
}

num totalAmount = 0;
var foundPriceMap = Map<String, FoundPrice>();

class _AnimatedListSampleState extends State<AnimatedListSample> {
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

    initialItems.addAll(defaultVarieties);
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
        body: RefreshIndicator(
          onRefresh: () async {
            update();
            print('refresh ');
          },
          child: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              key: _listKey,
              itemCount: _list.length,
              itemBuilder: _buildItem,
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

  // Used to build list items that haven't been removed.
  Widget _buildItem(BuildContext context, int index) {
    return new CardItem(
      item: _list[index],
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GridTransactionList(_list[index].id, foundPriceMap[_list[index].code].price);
        })).then((value) {
          update();
        });
      },
      onLongPress: () {
        showDialog(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) => DeleteVarietyDialog("请输入 ${_list[index].code}", (code) {
            setState(() {
              var needDelete = _list[index];
              _list.removeAt(index);
              deleteVariety(needDelete.id);
            });
          }, (code) {
            return code == _list[index].code;
          }),
        );
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

class CardItem extends StatelessWidget {
  const CardItem({
    Key key,
    this.onLongPress,
    this.onTap,
    @required this.item,
  }) : super(key: key);

  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Variety item;

  @override
  Widget build(BuildContext context) {
    return StatefulFoundCardItem(item, totalAmount, foundPriceMap[item.code], key, onLongPress, onTap);
  }
}


