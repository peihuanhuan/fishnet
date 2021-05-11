// import 'package:shared_preferences/shared_preferences.dart';

import 'package:fishnet/entity/Trade.dart';
import 'package:fishnet/entity/TwoDirectionTransactions.dart';
import 'package:fishnet/entity/Variety.dart';

import 'dart:convert';

var defaultVarieties = [
  Variety(
      1,
      "code",
      "华宝油气",
      [
        TwoDirectionTransactions(
            1, 1.0, Trade(1, 100, 2000, DateTime.now()), null),
        TwoDirectionTransactions(2, 0.95, Trade(1, 95, 3000, DateTime.now()),
            Trade(1, 100, 2000, DateTime.now()))
      ],
      DateTime.now()),

  Variety(
      2,
      "code",
      "华宝油气2",
      [
        TwoDirectionTransactions(
            1, 1.0, Trade(1, 10, 300, DateTime.now()), null),
        TwoDirectionTransactions(2, 0.95, Trade(1, 95, 3000, DateTime.now()),
            Trade(1, 100, 2000, DateTime.now()))
      ],
      DateTime.now())
];

Variety getByVarietyId(int id) {
  for (var value in defaultVarieties) {
    if(value.id == id) {
      return value;
    }
  }
}

Future<void> main() async {
  // final prefs = await SharedPreferences.getInstance();
  // prefs.setInt('counter', 111);
  // final counter = prefs.getInt('counter') ?? 0;

  var x = Variety(
      1,
      "code",
      "华宝油气",
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
