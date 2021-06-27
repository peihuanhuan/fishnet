import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:fishnet/colors/CardColor.dart';
import 'package:fishnet/domain/entity/FoundPrice.dart';
import 'package:fishnet/domain/entity/Variety.dart';

String toPercentage(num value) => (value * 100).toStringAsFixed(2) + "%";

int id() => DateTime.now().millisecondsSinceEpoch;

Color getMoneyColor(num totalProfit, CardColor cardColor) {
  var color = cardColor.flatColor;
  if(totalProfit > 0) {
    color = cardColor.profitColor;
  } else if(totalProfit < 0) {
    color = cardColor.lossColor;
  }
  return color;
}


extension ObjectExtension on Object {
  outlierDesc(num value, String desc) {
    var value = this;
    if (value is int || value is num || value is double) {
      return value == 0 ? desc : value;
    } else {
      return value;
    }
  }

  String objToString([int fractionDigits = 2]) {
    var value = this;
    if (value is String) {
      return value;
    }
    if (value is int) {
      return value.toString();
    }
    if (value is double) {
      return value.toStringAsFixed(fractionDigits);
    }
    if (value is num) {
      return value.toStringAsFixed(fractionDigits);
    }
    return value.toString();
  }
}

var httpClient = new HttpClient();

// todo 超时情况，无网络情况
Future<List<FoundPrice>> queryPrice(List<String> codes) async {
  var codesStr = codes.join(",");
  print('开始获取基金净值');
  var request = await httpClient.getUrl(Uri.parse("https://fishnet-api.peihuan.net/price?codes=$codesStr"));
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  var decodeJson = json.decode(responseBody) as List;

  return decodeJson.map((e) => FoundPrice.fromJson(e)).toList();
}

Future<String> queryName(String code) async {
  try {
    var request = await httpClient.getUrl(Uri.parse("https://fishnet-api.peihuan.net/name?code=$code"));
    var response = await request.close().timeout(Duration(seconds: 3));
    var responseBody = await response.transform(utf8.decoder).join();
    return responseBody;
  } on TimeoutException catch (_) {
    return "-";
  } on SocketException catch (_) {
    return "-";
  }
}
