import 'dart:io';

import 'package:fishnet/entity/FoundPrice.dart';
import 'package:fishnet/entity/Variety.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fishnet/MyCardItem.dart';
import 'persistences/PersistenceLayer.dart';
import 'package:flutter/services.dart';

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
  void initState()  {
    _list = new ListModel<Variety>(
      listKey: _listKey,
      initialItems: defaultVarieties,
      removedItemBuilder: _buildRemovedItem,
    );

    calcTotalAmount();

    print('initState done');
  }

  void calcTotalAmount() async {
    totalAmount = 0;
    for( var variety in _list._items) {
      var foundPrice = await queryPrice(variety.code);
      foundPriceMap[variety.code] = foundPrice;
      totalAmount +=  variety.holdingAmount(foundPrice.price);
      if(variety == _list._items.last) {
        print('------ totalAmount ' + totalAmount.toString());
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build _AnimatedListSampleState');
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('AnimatedList'),
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.add_circle),
              // onPressed: _insert,
              tooltip: 'insert a new item',
            ),
            new IconButton(
              icon: const Icon(Icons.remove_circle),
              // onPressed: _remove,
              tooltip: 'remove the selected item',
            ),
          ],
        ),
        floatingActionButton:
            MyFloat("新建网格", "", (code) => _insert(code), (code) {
          return code.length == 6;
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
              DialogStatefulWidget("删除网格", "输入${_list[index].name}代码", (code) {
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
  Future<void> _insert(String code) async {
    var name = await queryName(code);

    print('插入啦 $code $name');

    var variety = Variety(id(), code, name, List.empty(), DateTime.now());
    _list.insert(0, variety);
    setState(() {});
    defaultVarieties.add(variety);
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
    return StatefulFoundCardItem(item, totalAmount,foundPriceMap[item.code], UniqueKey(), onLongPress);
  }
}

class MyFloat extends StatefulWidget {
  String _dialogTitle;
  String _hintTitle;
  Function _insert;
  Function _checkOkButtonEnable;

  MyFloat(this._dialogTitle, this._hintTitle, this._insert,
      this._checkOkButtonEnable);

  @override
  _MyFloatState createState() => _MyFloatState();
}

class _MyFloatState extends State<MyFloat> {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
        child: Icon(Icons.add, color: Colors.black, size: 40),
        onPressed: () => _showMyDialog(context),
        backgroundColor: Colors.yellow);
  }

  Future<void> _showMyDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) => DialogStatefulWidget(
          widget._dialogTitle,
          widget._hintTitle,
          widget._insert,
          widget._checkOkButtonEnable),
    );
  }
}

class DialogStatefulWidget extends StatefulWidget {
  Function _okFunction;
  Function _checkOkButtonEnable;
  String _dialogTitle;
  String _hintTitle;

  DialogStatefulWidget(this._dialogTitle, this._hintTitle, this._okFunction,
      this._checkOkButtonEnable);

  @override
  _DialogStatefulWidgetState createState() => _DialogStatefulWidgetState();
}

class _DialogStatefulWidgetState extends State<DialogStatefulWidget> {
  int _loading = 0;
  String _code;
  bool disabled = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._dialogTitle),
      content: TextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "神秘代码",
          hintText: widget._hintTitle,
        ),
        maxLength: 6,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6)
        ],
        onChanged: (str) {
          _code = str;
          if (widget._checkOkButtonEnable(_code)) {
            setState(() {
              disabled = false;
            });
          }
        },
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

  Function onOkPressed(BuildContext context) {
    if (disabled) {
      return null;
    }
    return () async {
      setState(() {
        _loading = 1;
      });
      widget._okFunction(_code);
      setState(() {
        _loading = 0;
      });
      Navigator.of(context).pop();
    };
  }
}
