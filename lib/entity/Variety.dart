import 'package:fishnet/entity/TwoDirectionTransactions.dart';

class Variety {
  int id;

  // 代码
  String code;

  // 名字
  String name;

  List<TwoDirectionTransactions> transactions = List.empty();

  DateTime createTime;


  factory Variety.fromJson(Map<String, dynamic> json) {
    var transactions = <TwoDirectionTransactions>[];
    if(json['transactions'] != null) {
      var transactionsJson = json['transactions'];
      transactionsJson.forEach((v) {
        transactions.add(TwoDirectionTransactions.fromJson(v));
      });
    }

    return Variety(json['id'], json['code'], json['name'],
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
