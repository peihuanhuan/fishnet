// import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'package:fishnet/entity/Trade.dart';
import 'package:fishnet/entity/TwoDirectionTransactions.dart';
import 'package:fishnet/entity/Variety.dart';

import 'dart:convert';

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

Variety getByVarietyId(int id) {
  for (var value in defaultVarieties) {
    if(value.id == id) {
      return value;
    }
  }
}


_getIPAddress() async {
  var url = 'https://httpbin.org/ip';
  var httpClient = new HttpClient();

  String result;
  try {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.OK) {
      var json = await response.transform(utf8.decoder).join();
      var data = jsonDecode(json);
      result = data['origin'];
    } else {
      result =
      'Error getting IP address:\nHttp status ${response.statusCode}';
    }
  } catch (exception) {
    result = 'Failed getting IP address';
  }

  // If the widget was removed from the tree while the message was in flight,
  // we want to discard the reply rather than calling setState to update our
  // non-existent appearance.
}




Future<void> main() async {
  // final prefs = await SharedPreferences.getInstance();
  // prefs.setInt('counter', 111);
  // final counter = prefs.getInt('counter') ?? 0;
  var x = Variety(
      1,
      "159920",
      "恒生",
      [
        TwoDirectionTransactions(
            1, 1.0, Trade(1, 100, 2000, DateTime.now()), null),
        TwoDirectionTransactions(1, 0.95, Trade(1, 95, 3000, DateTime.now()),
            Trade(1, 100, 2000, DateTime.now()))
      ],
      DateTime.now());

  var jsonEncode2 = jsonEncode(x);
  print(jsonEncode2);

  var jsonDecode2 = jsonDecode(jsonEncode2);
  var variety = Variety.fromJson(jsonDecode2);
  print('');
}
