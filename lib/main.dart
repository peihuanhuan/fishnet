import 'dart:io';

import 'package:fishnet/entity/Variety.dart';
import 'package:fishnet/util/CommonUtils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fishnet/MyCardItem.dart';
import 'persistences/PersistenceLayer.dart';

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
        floatingActionButton: MyFloat(),
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
      item: index,
      onTap: () {},
    );
  }

  Widget _buildRemovedItem(
      int item, BuildContext context, Animation<double> animation) {
    return new CardItem(
      animation: animation,
      item: item,
    );
  }

// Insert the "next item" into the list model.
// void _insert() {
//   final int index = _selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
//   _list.insert(index, _nextItem++);
// }
//
// // Remove the selected item from the list model.
// void _remove() {
//   if (_selectedItem != null) {
//     _list.removeAt(_list.indexOf(_selectedItem));
//     setState(() {
//       _selectedItem = null;
//     });
//   }
// }

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
    this.onTap,
    @required this.item,
  })  : assert(animation != null),
        assert(item != null && item >= 0),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final int item;

  @override
  Widget build(BuildContext context) {
    return StatefulFoundCardItem(
        defaultVarieties[item], totalAmount, UniqueKey());
    // return ExpandedTile();
    // TextStyle textStyle = Theme.of(context).textTheme.display1;
    // if (selected)
    //   textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    // return new Padding(
    //   padding: const EdgeInsets.all(2.0),
    //   child: new SizeTransition(
    //     axis: Axis.vertical,
    //     sizeFactor: animation,
    //     child: new GestureDetector(
    //       behavior: HitTestBehavior.opaque,
    //       onTap: onTap,
    //       child: new SizedBox(
    //         height: 128.0,
    //         child: new Card(
    //           color: Colors.primaries[item % Colors.primaries.length],
    //           child: new Center(
    //             child: new Text('Item $item', style: textStyle),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class MyFloat extends StatefulWidget {


  @override
  _MyFloatState createState() => _MyFloatState();
}

class _MyFloatState extends State<MyFloat> {

  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
        child: Icon(Icons.add, color: Colors.black, size: 40,),
        onPressed: () => _showMyDialog(context),
        backgroundColor: Colors.yellow
    );
  }

  Future<void> _showMyDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) => DialogStatefulWidget(),
    );
  }

}

class DialogStatefulWidget extends StatefulWidget {

  @override
  _DialogStatefulWidgetState createState() => _DialogStatefulWidgetState();
}

class _DialogStatefulWidgetState extends State<DialogStatefulWidget> {
  int _loading = 0;
  var _code;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('新建网格'),
      content: TextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: "神秘代码",
          hintText: "大富大贵",
        ),
        onChanged: (str) {
          _code = str;
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Row(
            key: UniqueKey(),
            children: [
              Text('确认'),
              Container(
                  height: 15.0 * _loading,
                  width: 15,
                  child: CircularProgressIndicator()),
            ],
          ),
          onPressed: () async {
            setState(() {
              _loading = 1;
            });
            var queryName2 = await queryName(_code);
            print(queryName2);
              setState(() {
                _loading = 0;
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
