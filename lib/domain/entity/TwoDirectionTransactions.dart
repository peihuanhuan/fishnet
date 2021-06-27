

// 某个档位上的两次交易
import 'dart:math';

import 'Trade.dart';

class TwoDirectionTransactions {
  // 档位，从 1 开始
  int id;
  num level;
  Trade buy;
  Trade sell;

  //todo 一些标记，如 网的比例
  String tag;


  TwoDirectionTransactions(this.id, this.level, this.buy, this.sell);

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
    'buy': buy.toJson(),
    'sell': sell == null ? null : sell.toJson()
  };

  TwoDirectionTransactions.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        level = json['level'],
        buy = Trade.fromJson(json['buy']),
        sell = Trade.fromJson(json['sell']);

  // 总盈利
  num totalProfit(num currentPrice) {
    return realProfit() + floatingProfit(currentPrice);
  }

  // 实盈
  num realProfit() {
    return sell == null ? 0 : sell.number * (sell.price - buy.price);
  }


  // 成本
  num costAmount() {
    if(sell == null) {
      return buy.getAmount();
    } else {
      return buy.getAmount() - sell.getAmount();
    }
  }


  // 虚盈
  num floatingProfit(num currentPrice) {

    if(currentPrice == 0) {
      // 未获取到
      return 0;
    }
    return (currentPrice - buy.price) * retainedNumber();
  }

  // 持有金额
  num holdingAmount(num currentPrice) {
    if(currentPrice == 0) {
      return costAmount();
    }
    return currentPrice * retainedNumber();
  }

  // 持有天数
  int holdingDays() {
    return max((sell == null ? DateTime.now() : sell.time).difference(buy.time).inDays, 1);
  }

  // 年化率
  num annualizedRate(num currentPrice) {
    // fix 需要按照金额比重计算
    return totalProfit(currentPrice) / (buy.price * buy.number) * (365 / holdingDays());
  }

  // 持有数量
  int retainedNumber() {
    if (sell == null) {
      return buy.number;
    }
    return buy.number - sell.number;
  }
}