// 品种
import 'dart:math';

class Variety {
  int id;

  // 代码
  String code;

  // 名字
  String name;

  DateTime createTime;

  Variety(this.code, this.name);

  Variety.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        code = json['code'],
        name = json['name'],
        createTime = DateTime.fromMillisecondsSinceEpoch(json['create_time']);

  Map<String, dynamic> toDbJson() =>
      {
        'id': id,
        'name': name,
        'code': code
      };

  Map<String, dynamic> toJson() {
    var dbJson = toDbJson();
    dbJson["create_time"] = createTime.millisecondsSinceEpoch;
    return dbJson;
  }
}

// 某个档位上的两次交易
class TwoDirectionTransactions {
  // 档位，从 1 开始
  num level;
  Trade buy;
  Trade sell;

  // 一些标记，如 网的比例
  String tag;

  TwoDirectionTransactions(this.level, this.buy, this.sell);

  num profit() {
    return sell.number * (sell.price - buy.price);
  }

  int holdingDays() {
    return max(sell.time.difference(buy.time).inDays, 1);
  }

  num annualizedRate() {
    return profit() / (buy.price * buy.number) * (365 / holdingDays());
  }

  int retainedNumber() {
    return sell.number - buy.number;
  }
}

class Trade {
  int id;

  // 交易价格
  num price;

  // 交易数量
  int number;

  // 交易时间
  DateTime time;

  Trade(this.price, this.number, this.time);
}
