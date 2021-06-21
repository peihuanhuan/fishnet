import 'dart:io';

import 'package:fishnet/util/CommonUtils.dart';
import 'package:fishnet/util/CommonWight.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fishnet/MyCardItem.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  final GlobalKey<AnimatedListState> _listKey =
      new GlobalKey<AnimatedListState>();
  ListModel<Variety> _list;

  @override
  void initState() {
    init();
  }

  Future init() async {
    _list = new ListModel<Variety>(
      listKey: _listKey,
      initialItems: [],
      removedItemBuilder: _buildRemovedItem,
    );

    var initialItems = await getVarieties();
    _list = new ListModel<Variety>(
      listKey: _listKey,
      initialItems: initialItems,
      removedItemBuilder: _buildRemovedItem,
    );
    setState(() {

    });
    calcTotalAmount();
  }

  void calcTotalAmount() async {
    var foundPrices =
        await queryPrice(_list._items.map((e) => e.code).toList());

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
        floatingActionButton: AddVarietyFloat((_code, _mesh, _firstPrice, _firstNumber, _tag) => _insert(_code, _mesh, _firstPrice, _firstNumber, _tag),
            (_code, _mesh, _firstPrice, _firstNumber) {
          return _code.toString().length == 6 &&
              _firstPrice != null &&
              _firstPrice > 0 &&
              _firstNumber != null &&
              _firstNumber > 100;
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: new Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            key: _listKey,
            itemCount: _list.length,
            itemBuilder: _buildItem,
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
      onLongPress: () {
        showDialog(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) =>
              DeleteVarietyDialogStatefulWidget("请输入 ${_list[index].code}", (code) {
            setState(() {
              //todo 持久化
              _list.removeAt(index);
            });
          }, (code) {
            return code == _list[index].code;
          }),
        );
      },
    );
  }

  Widget _buildRemovedItem(
      Variety item, BuildContext context, Animation<double> animation) {
    return new CardItem(
      // animation: animation,
      item: item,
    );
  }

// Insert the "next item" into the list model.
  Future<void> _insert(code, mesh, firstPrice, firstNumber, tag) async {
    var name = await queryName(code.toString());

    print('插入啦 $code $name');

    var variety = Variety(id(), code,
        name, mesh, firstPrice, firstNumber,tag, [], DateTime.now());
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
    @required this.item,
  }) : super(key: key);

  final VoidCallback onLongPress;
  final Variety item;

  @override
  Widget build(BuildContext context) {
    return StatefulFoundCardItem(
        item, totalAmount, foundPriceMap[item.code], UniqueKey(), onLongPress);
  }
}

class AddVarietyFloat extends StatefulWidget {
  Function _insert;
  Function _checkOkButtonEnable;

  AddVarietyFloat(this._insert,
      this._checkOkButtonEnable);

  @override
  _AddVarietyFloatState createState() => _AddVarietyFloatState();
}

class _AddVarietyFloatState extends State<AddVarietyFloat> {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
        child: Icon(Icons.add, color: Colors.black, size: 40),
        onPressed: () => _showMyDialog(context),
        backgroundColor: Color(0xFFFFD103));
  }

  Future<void> _showMyDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) => AddVarietyDialogStatefulWidget(
          widget._insert,
          widget._checkOkButtonEnable),
    );
  }
}

class AddVarietyDialogStatefulWidget extends StatefulWidget {
  Function _okFunction;
  Function _checkOkButtonEnable;

  AddVarietyDialogStatefulWidget(this._okFunction,
      this._checkOkButtonEnable);

  @override
  _AddVarietyDialogStatefulWidgetState createState() => _AddVarietyDialogStatefulWidgetState();
}

class _AddVarietyDialogStatefulWidgetState extends State<AddVarietyDialogStatefulWidget> {
  int _loading = 0;
  num _code;
  num _firstNumber;
  num _firstPrice;
  bool enable = false;
  num _mesh = 0.05;
  String _tag = "";


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("新建网格"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          numberFieldInputWidget("代码", (value) {
            _code = value;
            checkClickable();
          }, maxLength: 6),
          customFieldInputWidget("网格大小", DropdownButton<int>(
              value: (_mesh * 100).toInt(),
              isExpanded: true,
              items: items(),
              onChanged: (value) {
                setState(() {
                  _mesh = value / 100;
                });
              })),
          numberFieldInputWidget("第一网价格", (value) {
            _firstPrice = value;
            checkClickable();
          }, isPrice: true, limit: 7),

          numberFieldInputWidget("第一网数量", (value) {
            _firstNumber = value;
            checkClickable();
          }),
          stringFieldInputWidget("标签", (value) {
            _tag = value;
          }, hintText: "小备注"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
            child: Row(
              children: [
                Text('确认'),
                Container(
                    height: 15.0 * _loading,
                    width: 15,
                    child: CircularProgressIndicator()),
              ],
            ),
            onPressed: onOkPressed(context)),
      ],
    );
  }

  List<DropdownMenuItem<int>> items() {
    var items = [3,4,5,6,7,8,9,10,12,15,20,30];
    return items.map((e) => DropdownMenuItem(value: e, child: Text('$e%'))).toList();
  }

  void checkClickable() {
    setState(() {
      enable =
          widget._checkOkButtonEnable(_code.toString(), _mesh, _firstPrice, _firstNumber);
    });
  }

  Function onOkPressed(BuildContext context) {
    if (!enable) {
      return null;
    }
    return () async {
      setState(() {
        _loading = 1;
      });
      widget._okFunction(_code.toString(), _mesh, _firstPrice, _firstNumber, _tag);
      setState(() {
        _loading = 0;
      });
      Navigator.of(context).pop();
    };
  }
}



class DeleteVarietyDialogStatefulWidget extends StatefulWidget {
  Function _okFunction;
  Function _checkOkButtonEnable;
  String _hintTitle;

  DeleteVarietyDialogStatefulWidget(this._hintTitle, this._okFunction,
      this._checkOkButtonEnable);

  @override
  _DeleteVarietyDialogStatefulWidget createState() => _DeleteVarietyDialogStatefulWidget();
}

class _DeleteVarietyDialogStatefulWidget extends State<DeleteVarietyDialogStatefulWidget> {
  num _code;
  bool enable = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("删除网格"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          numberFieldInputWidget("代码", (value) {
            _code = value;
            checkClickable();
          }, hintText: widget._hintTitle),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
            child: Row(
              children: [
                Text('确认'),
              ],
            ),
            onPressed: onOkPressed(context)),
      ],
    );
  }


  void checkClickable() {
    setState(() {
      enable =
          widget._checkOkButtonEnable(_code.toString());
    });
  }

  Function onOkPressed(BuildContext context) {
    if (!enable) {
      return null;
    }
    return () async {
      widget._okFunction(_code.toString());
      Navigator.of(context).pop();
    };
  }
}
