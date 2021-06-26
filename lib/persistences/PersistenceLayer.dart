// import 'package:shared_preferences/shared_preferences.dart';


import 'dart:convert';

import 'package:fishnet/domain/entity/Variety.dart';
import 'package:shared_preferences/shared_preferences.dart';

var defaultVarieties = [
  Variety.fromJson(jsonDecode(yiyao)),
  Variety.fromJson(jsonDecode(chuanmei)),
  Variety.fromJson(jsonDecode(zhenquan)),
];

var yiyao = """
{
  "id": 1,
  "name": "医药",
  "code": "159938",
  "mesh": 0.05,
  "firstPrice": 1.900,
  "firstNumber": 2600,
  "transactions": [
    {
      "id": 1,
      "level": 1.0,
      "buy": {
        "id": 1,
        "price": 1.900,
        "number": 2600,
        "time": 1606354560000
      },
      "sell": {
        "id": 2,
        "price": 1.995,
        "number": 2400,
        "time": 1606959360000
      }
    },
        {
      "id": 1,
      "level": 1.0,
      "buy": {
        "id": 1,
        "price": 1.900,
        "number": 2600,
        "time": 1615772160000
      },
      "sell": {
        "id": 2,
        "price": 1.995,
        "number": 2400,
        "time": 1616722560000
      }
    }
  ],
  "createTime": 1606354560000
}
""";

var chuanmei = """
{
  "id": 3,
  "name": "传媒",
  "code": "512980",
  "mesh": 0.05,
  "firstPrice": 0.860,
  "firstNumber": 5900,
  "transactions": [
    {
      "id": 1,
      "level": 1.0,
      "buy": {
        "id": 1,
        "price": 0.860,
        "number": 5900,
        "time": 1608082560000
      },
      "sell": null
    }
  ],
  "createTime": 1608082560000
}

""";

var zhenquan = """

{
  "id": 2,
  "name": "证券",
  "code": "512880",
  "mesh": 0.05,
  "firstPrice": 1.030,
  "firstNumber": 4800,
  "transactions": [
    {
      "id": 1,
      "level": 1.0,
      "buy": {
        "id": 1,
        "price": 1.030,
        "number": 4800,
        "time": 1618191360000
      },
      "sell": null
    }
  ],
  "createTime": 1618191360000
}


""";

Future<Variety> getByVarietyId(int id) async {
  var varieties = await getVarieties();
  for (var value in varieties) {
    if(value.id == id) {
      return value;
    }
  }
}


Future<List<Variety>> getVarieties() async {
  final prefs = await SharedPreferences.getInstance();
  var stringList = prefs.getStringList('varieties') ?? [];
  List<Variety> varieties = [];
  stringList.forEach((str) {
    varieties.add(Variety.fromJson(jsonDecode(str)));
  });
  return varieties;
}


Future<void> deleteVariety(num id) async {
  final prefs = await SharedPreferences.getInstance();
  var stringList = prefs.getStringList('varieties') ?? [];
  List<String> needSaveVarieties = [];
  stringList.forEach((str) {
    var variety = Variety.fromJson(jsonDecode(str));
    if(variety.id != id) {
      needSaveVarieties.add(str);
    }
  });
  prefs.setStringList('varieties', needSaveVarieties);
}

Future<void> saveVariety(Variety needUpdateVariety) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> stringList = prefs.getStringList('varieties') ?? [];

  List<Variety> newVarieties = [];

  int index = 0;
  for (var entry in stringList.asMap().entries) {
    var variety = Variety.fromJson(jsonDecode(entry.value));
    if(variety.id != needUpdateVariety.id) {
      newVarieties.add(variety);
    } else {
      index = entry.key;
    }
  }

  newVarieties.insert(index, needUpdateVariety);

  var list = newVarieties.map((e) => json.encoder.convert(e)).toList();
  prefs.setStringList('varieties', list);
}


