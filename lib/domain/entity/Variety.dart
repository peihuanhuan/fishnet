import 'package:fishnet/domain/dto/PriceNumberPair.dart';

import 'Trade.dart';
import 'TwoDirectionTransactions.dart';

class Variety {
  int id;

  // todo tojson
  num mesh;
  num firstPrice;
  int firstNumber;

  // 代码
  String code;

  // 名字
  String name;

  List<TwoDirectionTransactions> transactions = List.empty();

  DateTime createTime;

  PriceNumberPair quickOperate(bool buy) {
    var lastOperateTime = DateTime.utc(0);
    TwoDirectionTransactions lastTransaction;
    for (var transaction in transactions) {
      if (transaction.buy.time.isAfter(lastOperateTime)) {
        lastOperateTime = transaction.buy.time;
        lastTransaction = transaction;
      }
      if (transaction.sell != null &&
          transaction.sell.time.isAfter(lastOperateTime)) {
        lastOperateTime = transaction.sell.time;
        lastTransaction = transaction;
      }
      if (lastTransaction == null) {
        return null;
      }

      if (buy) {
        if (lastTransaction.sell == null) {
          // 下个档位的 买点
          return findPrice(lastTransaction.level - mesh, buy);
        } else {
          // 买这个档位的 价钱
          return findPrice(lastTransaction.buy.price, buy);
        }
      }

      if (!buy) {
        if (lastTransaction.sell == null) {
          // 卖这个 档位的价钱
          return findPrice(lastTransaction.level, buy);
        } else {
          // 上个档位的 卖点
          return findPrice(lastTransaction.level + mesh, buy);
        }
      }
    }
  }

  PriceNumberPair findPrice(num level, bool buy) {
    var lastOperateTime = DateTime.utc(0);
    var price = firstPrice * level;
    // todo 这需要确定
    var number = firstNumber * (level - mesh);
    if(!buy) {
      price += price * mesh;
    }
    for (var transaction in transactions) {
      Trade trade = buy ? transaction.buy : transaction.sell;
      if (trade.time.isAfter(lastOperateTime)) {
        lastOperateTime = trade.time;
        price = trade.price;
        number = trade.number;
      }
    }
    return PriceNumberPair(price, number);
  }

  factory Variety.fromJson(Map<String, dynamic> json) {
    var transactions = <TwoDirectionTransactions>[];
    if (json['transactions'] != null) {
      var transactionsJson = json['transactions'];
      transactionsJson.forEach((v) {
        transactions.add(TwoDirectionTransactions.fromJson(v));
      });
    }

    return Variety(json['id'], json['code'], json['name'], transactions,
        DateTime.fromMillisecondsSinceEpoch(json['createTime']));
  }

  Map<String, dynamic> toJson() {
    var transactionsJson = [];
    for (var transaction in transactions) {
      transactionsJson.add(transaction.toJson());
    }
    return {
      'id': id,
      'name': name,
      'code': code,
      'transactions': transactionsJson,
      'createTime': createTime.millisecondsSinceEpoch
    };
  }

  Variety(this.id, this.code, this.name, this.transactions, this.createTime);

  num totalProfit(num currentPrice) {
    return transactions
        .map((e) => e.totalProfit(currentPrice))
        .fold(0, (curr, next) => curr + next);
  }

  num floatingProfit(num currentPrice) {
    return transactions
        .map((e) => e.floatingProfit(currentPrice))
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

  num holdingAmount(num currentPrice) {
    return transactions
        .map((e) => e.holdingAmount(currentPrice))
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
}
