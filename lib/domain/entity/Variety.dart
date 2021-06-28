import 'package:decimal/decimal.dart';
import 'package:fishnet/domain/dto/PriceNumberPair.dart';
import 'package:fishnet/main.dart';
import 'package:fishnet/util/CommonUtils.dart';

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

  List<TwoDirectionTransactions> transactions = [];

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
        var nextLevel = num.parse((Decimal.parse(lastTransaction.level.toString()) - Decimal.parse(mesh.toString())).toString());
        if(nextLevel <= 0) {
          return null;
        }
        return calcPrice(nextLevel, buy);
      } else {
        // 买这个档位的 价钱
        return calcPrice(lastTransaction.level, buy);
      }
    }

    if (!buy) {
      if (lastTransaction.sell == null) {
        // 卖这个 档位的价钱
        return calcPrice(lastTransaction.level, buy);
      } else {
        var lastLevel = num.parse((Decimal.parse(lastTransaction.level.toString()) + Decimal.parse(mesh.toString())).toString());

        // 寻找是否有可以卖的
        var ts = [];
        ts.addAll(transactions);

        ts.sort((a, b) => b.buy.time.microsecond.compareTo(a.buy.time.microsecond));
        for (var transaction in ts) {
          if (transaction.level == lastLevel && transaction.sell == null) {
            return calcPrice(lastLevel, buy);
          }
        }
        return null;
      }
    }
  }

  PriceNumberPair calcPrice(num level, bool buy) {
    var lastOperateTime = DateTime.utc(0);
    num price;
    int number;
    if(buy) {
      price = num.parse((firstPrice * level).toStringAsFixed(3));
      number =  ((1 / level * firstNumber / 100).ceil() * 100).toInt();
    } else {
      // 买的价格要多网格的网眼
      price = num.parse((firstPrice * (level + mesh)).toStringAsFixed(3));
      // 留存一倍利润  todo fix 不对算法
      number = ((firstNumber / (level + mesh) / 100).floor() * 100).toInt();
    }
    for (var transaction in transactions) {
      Trade trade = buy ? transaction.buy : transaction.sell;
      if (trade != null && trade.time.isAfter(lastOperateTime) && level == transaction.level) {
        lastOperateTime = trade.time;
        price = trade.price;
        number = ((trade.number / 100).ceil() * 100).toInt();
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



  int totalCost() {
    return transactions.map((e) => e.costAmount())
        .fold(0, (curr, next) => curr + next);
  }

  num averageCost() {
    var totalNumber = retainedNumber();


    if(totalNumber == 0) {
      return NO_COST;
    }
    return totalCost() / totalNumber;
  }

  int retainedNumber() {
    return transactions.map((e) => e.retainedNumber())
        .fold(0, (curr, next) => curr + next);
  }

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
