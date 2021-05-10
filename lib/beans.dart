// 品种
import 'dart:math';

class Variety {
  int id;

  // 代码
  String code;

  // 名字
  String name;

  // 当前价格
  num currentPrice = 0;

  List<TwoDirectionTransactions> transactions = List.empty();

  DateTime createTime;

  Variety(this.code, this.name);

  num totalProfit() {
    return transactions
        .map((e) => e.totalProfit())
        .fold(0, (curr, next) => curr + next);
  }

  num floatingProfit() {
    return transactions
        .map((e) => e.floatingProfit())
        .fold(0, (curr, next) => curr + next);
  }

  num realProfit() {
    return transactions
        .map((e) => e.realProfit())
        .fold(0, (curr, next) => curr + next);
  }

  num annualizedRate() {
    return 0.11;
  }

  num holdingAmount() {
    return transactions
        .map((e) => e.holdingAmount())
        .fold(0, (curr, next) => curr + next);
  }

  int twoWayFrequency() {
    int count = 0;
    for (var transaction in transactions) {
      if (transaction.sell != null) {
        count++;
      }
    }
    return count;
  }

  // todo 少个属性
  Variety.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        code = json['code'],
        name = json['name'],
        createTime = DateTime.fromMillisecondsSinceEpoch(json['create_time']);

  Map<String, dynamic> toDbJson() => {'id': id, 'name': name, 'code': code};

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

  num currentPrice = 0;

  TwoDirectionTransactions(this.level, this.buy, this.sell);

  // 总盈利
  num totalProfit() {
    return realProfit() + floatingProfit();
  }

  // 实盈
  num realProfit() {
    return sell == null ? 0 : sell.number * (sell.price - buy.price);
  }

  // 虚盈
  num floatingProfit() {
    return (currentPrice - buy.price) * retainedNumber();
  }

  // 持有金额
  num holdingAmount() {
    return currentPrice * retainedNumber();
  }

  // 持有天数
  int holdingDays() {
    return max(sell.time.difference(buy.time).inDays, 1);
  }

  // 年化率
  num annualizedRate() {
    // fix 需要按照金额比重计算
    return totalProfit() / (buy.price * buy.number) * (365 / holdingDays());
  }

  // 持有数量
  int retainedNumber() {
    if (sell == null) {
      return buy.number;
    }
    return buy.number - sell.number;
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
