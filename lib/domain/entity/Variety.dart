import 'package:decimal/decimal.dart';
import 'package:fishnet/domain/dto/Operator.dart';
import 'package:fishnet/domain/dto/PriceNumberPair.dart';
import 'package:fishnet/main.dart';
import 'package:fishnet/util/CommonUtils.dart';

import 'Trade.dart';
import 'TwoDirectionTransactions.dart';

class Variety {
  int _id;

  int get id => _id;

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

  // 根据现价，预判 幅度
  num predictCurrentLevel(num currentPrice) {
    num level = 1;
    if (currentPrice > (level + mesh / 2) * firstPrice) {
      return 1;
    }
    while (level > 0) {
      if (currentPrice > (level - mesh / 2) * firstPrice && currentPrice < (level + mesh / 2) * firstPrice) {
        return level;
      }
      level = minusAccurately(level, mesh);
    }
    return addAccurately(level, mesh);
  }


  Operator buyOperateWithLevel(num currentPriceLevel) {
    var price = calcPrice(currentPriceLevel, true);
    for (var value in transactions) {
      if(value.level == currentPriceLevel && value.sell == null) {
          return Operator.success(price, extraMessage: "已买入一网尚未卖出。");
      }
    }

    return Operator.success(price);
  }


  Operator sellOperateWithLevel(num currentPriceLevel) {

    // 寻找是否有可以卖的
    List<TwoDirectionTransactions> ts = [];
    for (var value in transactions) {
      if (value.sell == null) {
        ts.add(value);
      }
    }
    // 后买的排在前面
    ts.sort((a, b) => b.buy.time.compareTo(a.buy.time));

    if(ts.isEmpty) {
      return Operator.fail("没有尚未卖出的网。");
    }

    for (var v in ts) {
      var msg;
      if (v.level < currentPriceLevel) {
        msg = "有价格更低，但未卖出的网，请注意。";
      } else if (v.level == currentPriceLevel) {
        return Operator.success(calcPrice(currentPriceLevel, false), extraMessage: msg);
      }
    }
    return Operator.fail("现在的价格，没有匹配到可以卖出的网。");
  }

  Operator quickOperate(bool buy, num currentPrice) {
    if(currentPrice == 0) {
      return quickOperateWithoutPrice(buy);
    }

    var currentPriceLevel = predictCurrentLevel(currentPrice);
    if(buy) {
      return buyOperateWithLevel(currentPriceLevel);
    } else {
      currentPriceLevel -= mesh;

      return sellOperateWithLevel(currentPriceLevel);
    }
  }

  Operator quickOperateWithoutPrice(bool buy) {
    var lastOperateTime = DateTime.utc(0);
    TwoDirectionTransactions lastTransaction;

    if (transactions.isEmpty) {
      if (buy) {
        return Operator.success(PriceNumberPair(1, firstPrice, firstNumber));
      } else {
        return Operator.fail("没有买入记录");
      }
    }
    for (var transaction in transactions) {
      if (transaction.buy.time.isAfter(lastOperateTime)) {
        lastOperateTime = transaction.buy.time;
        lastTransaction = transaction;
      }
      if (transaction.sell != null && transaction.sell.time.isAfter(lastOperateTime)) {
        lastOperateTime = transaction.sell.time;
        lastTransaction = transaction;
      }
    }

    if (buy) {
      if (lastTransaction.sell == null) {
        // 下个档位的 买点
        var nextLevel = minusAccurately(lastTransaction.level, mesh);
        if (nextLevel <= 0) {
          return null;
        }
        return Operator.success(calcPrice(nextLevel, buy));
      } else {
        // 买这个档位的 价钱
        return Operator.success(calcPrice(lastTransaction.level, buy));
      }
    }

    if (!buy) {
      if (lastTransaction.sell == null) {
        // 卖这个 档位的价钱
        return Operator.success(calcPrice(lastTransaction.level, buy));
      } else {

        // 还要再往上卖一个档位
        var lastLevel = addAccurately(lastTransaction.level, mesh);

        // 寻找是否有可以卖的
        var ts = [];
        ts.addAll(transactions);

        ts.sort((a, b) => b.buy.time.microsecond.compareTo(a.buy.time.microsecond));
        for (var transaction in ts) {
          if (transaction.level == lastLevel && transaction.sell == null) {
            return Operator.success(calcPrice(lastLevel, buy));
          }
        }

        // todo 如果 中间有个操作没被记录到，可能也没找到，因为是查询最后一次交易。
        return Operator.fail("没找到可以卖的啦");
      }
    }
  }

  PriceNumberPair calcPrice(num level, bool buy) {
    var lastOperateTime = DateTime.utc(0);
    num price;
    int number;
    if (buy) {
      price = num.parse((firstPrice * level).toStringAsFixed(3));
      number = ((1 / level * firstNumber / 100).ceil() * 100).toInt();
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

    return Variety(json['id'], json['code'], json['name'], json['mesh'], json['firstPrice'], json['firstNumber'],
        json['tag'], transactions, DateTime.fromMillisecondsSinceEpoch(json['createTime']));
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

  Variety(this._id, this.code, this.name, this.mesh, this.firstPrice, this.firstNumber, this.tag, this.transactions,
      this.createTime);

  num totalCost() {
    return transactions.map((e) => e.costAmount()).fold(0, (curr, next) => curr + next);
  }

  num averageCost() {
    var totalNumber = retainedNumber();

    if (totalNumber == 0) {
      return NO_COST;
    }
    return totalCost() / totalNumber;
  }

  int retainedNumber() {
    return transactions.map((e) => e.retainedNumber()).fold(0, (curr, next) => curr + next);
  }

  num totalProfit(num currentPrice) {
    return transactions.map((e) => e.totalProfit(currentPrice)).fold(0, (curr, next) => curr + next);
  }

  num floatingProfit(num currentPrice) {
    return transactions.map((e) => e.floatingProfit(currentPrice)).fold(0, (curr, next) => curr + next);
  }

  num realProfit() {
    return transactions.map((e) => e.realProfit()).fold(0, (curr, next) => curr + next);
  }

  num annualizedRate() {
    return 0.11;
  }

  num holdingAmount(num currentPrice) {
    return transactions.map((e) => e.holdingAmount(currentPrice)).fold(0, (curr, next) => curr + next);
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
