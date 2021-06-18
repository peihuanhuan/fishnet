import 'package:fishnet/domain/dto/PriceNumberPair.dart';

import 'Trade.dart';
import 'TwoDirectionTransactions.dart';

class Variety {
  int id;

  // 代码
  String code;

  // 名字
  String name;

  num mesh;
  num firstPrice;
  int firstNumber;

  List<TwoDirectionTransactions> transactions = List.empty();

  DateTime createTime;

  // 简短的标签，备注
  String tag;

  PriceNumberPair quickOperate(bool buy) {
    var lastOperateTime = DateTime.utc(0);
    TwoDirectionTransactions lastTransaction;

    if (transactions.isEmpty) {
      if (buy) {
        return PriceNumberPair(1, firstPrice, firstNumber);
      } else {
        return null;
      }
    }
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
        if (buy) {
          return PriceNumberPair(1, firstPrice, firstNumber);
        } else {
          return null;
        }
      }

      if (buy) {
        if (lastTransaction.sell == null) {
          // 下个档位的 买点
          return findPrice(lastTransaction.level - mesh, buy);
        } else {
          // 买这个档位的 价钱
          return findPrice(lastTransaction.level, buy);
        }
      }

      if (!buy) {
        if (lastTransaction.sell == null) {
          // 卖这个 档位的价钱
          return findPrice(lastTransaction.level, buy);
        } else {
          // 寻找是否有可以卖的
          transactions.sort((a, b) =>
              b.buy.time.microsecond.compareTo(a.buy.time.microsecond));
          for (var transaction in transactions) {
            if (transaction.level == lastTransaction.level + mesh &&
                transaction.sell == null) {
              return PriceNumberPair(lastTransaction.level + mesh,
                  transaction.sell.price, transaction.sell.number);
            }
          }
          return null;
        }
      }
    }
  }

  PriceNumberPair findPrice(num level, bool buy) {
    var lastOperateTime = DateTime.utc(0);
    var price = firstPrice * level;
    // todo 这需要确定
    var number = firstNumber * (level - mesh);
    if (!buy) {
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
    return PriceNumberPair(level, price, number);
  }

  factory Variety.fromJson(Map<String, dynamic> json) {
    var transactions = <TwoDirectionTransactions>[];
    if (json['transactions'] != null) {
      var transactionsJson = json['transactions'];
      transactionsJson.forEach((v) {
        transactions.add(TwoDirectionTransactions.fromJson(v));
      });
    }

    return Variety(
        json['id'],
        json['code'],
        json['name'],
        json['mesh'],
        json['firstPrice'],
        json['firstNumber'],
        json['tag'],
        transactions,
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
      'mesh': mesh,
      'firstNumber': firstNumber,
      'firstPrice': firstPrice,
      'tag': tag,
      'createTime': createTime.millisecondsSinceEpoch
    };
  }

  Variety(this.id, this.code, this.name, this.mesh, this.firstPrice,
      this.firstNumber, this.tag, this.transactions, this.createTime);

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
