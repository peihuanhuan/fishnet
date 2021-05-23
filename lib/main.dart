import 'dart:io';

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

num totalAmount = 0;

class AnimatedListSample extends StatefulWidget {
  @override
  _AnimatedListSampleState createState() => new _AnimatedListSampleState();
}

class _AnimatedListSampleState extends State<AnimatedListSample> {
  final GlobalKey<AnimatedListState> _listKey =
      new GlobalKey<AnimatedListState>();
  ListModel<Variety> _list;
  int _nextItem; // The next item inserted when the user presses the '+' button.

  @override
  void initState() {
    _list = new ListModel<Variety>(
      listKey: _listKey,
      initialItems: defaultVarieties,
      removedItemBuilder: _buildRemovedItem,
    );
    _nextItem = 3;

    Function callback = (t) {
      totalAmount = t;
      print('------ totalAmount ' + totalAmount.toString());
      setState(() {});
    };

    calcTotalAmount(_list._items, callback);
  }

  @override
  Widget build(BuildContext context) {
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
        floatingActionButton: MyFloat((code, name) => _insert(code, name)),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new AnimatedList(
            key: _listKey,
            initialItemCount: _list.length,
            itemBuilder: _buildItem,
          ),
        ),
      ),
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return new CardItem(
      animation: animation,
      item: _list[index],
      onLongPress: () {
        _list.removeAt(index);
        print('长按 $index');
        setState(() {

        });
      },
    );
  }

  Widget _buildRemovedItem(
      Variety item, BuildContext context, Animation<double> animation) {
    return new CardItem(
      animation: animation,
      item: item,
    );
  }

// Insert the "next item" into the list model.
  void _insert(String code, String name) {
    print('插入啦 $code $name');

    var variety = Variety(id(), code, name, List.empty(), DateTime.now());
    _list.insert(0, variety);
    defaultVarieties.add(variety);
  }
void _remove(Variety variety) {
    _list.removeAt(_list.indexOf(variety));
    setState(() {
    });
  }
}


/// Keeps a Dart List in sync with an AnimatedList.
///
/// The [insert] and [removeAt] methods apply to both the internal list and the
/// animated list that belongs to [listKey].
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that mutate the
/// list must make the same changes to the animated list in terms of
/// [AnimatedListState.insertItem] and [AnimatedList.removeItem].
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

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(index,
          (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(removedItem, context, animation);
      });
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

class CardItem extends StatelessWidget {
  const CardItem({
    Key key,
    @required this.animation,
    this.onLongPress,
    @required this.item,
  }) : super(key: key);

  final Animation<double> animation;
  final VoidCallback onLongPress;
  final Variety item;

  @override
  Widget build(BuildContext context) {
    return StatefulFoundCardItem(item, totalAmount, UniqueKey(), onLongPress);
  }
}

class MyFloat extends StatefulWidget {
  Function _insert;

  MyFloat(this._insert);

  @override
  _MyFloatState createState() => _MyFloatState();
}

class _MyFloatState extends State<MyFloat> {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 40,
        ),
        onPressed: () => _showMyDialog(context),
        backgroundColor: Colors.yellow);
  }

  Future<void> _showMyDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) => DialogStatefulWidget(widget._insert),
    );
  }
}

class DialogStatefulWidget extends StatefulWidget {
  Function insert;

  DialogStatefulWidget(this.insert);

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
      title: Text('新建网格'),
      content: TextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "神秘代码",
          hintText: "",
        ),
          maxLength: 6,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6)
          ],
        onChanged: (str) {
          _code = str;
          if(_code.length == 6) {
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
          onPressed:  onOkPressed(context)
        ),
      ],
    );
  }

  Function onOkPressed(BuildContext context) {
    if(disabled) {
      return null;
    }
    return () async {
      setState(() {
        _loading = 1;
      });
      var name = await queryName(_code);
      widget.insert(_code, name);
      setState(() {
        _loading = 0;
      });
      Navigator.of(context).pop();
    };
  }
}
