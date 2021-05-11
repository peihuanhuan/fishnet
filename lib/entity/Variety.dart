import 'package:fishnet/entity/TwoDirectionTransactions.dart';

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

  //
  // Variety.fromJson(Map<String, dynamic> json) {
  //   id = json["id"]?.toInt();
  //   code = json["code"]?.toString();
  //   name = json["name"]?.toString();
  //   if (json["transactions"] != null) {
  //     final v = json["transactions"];
  //     final arr0 = <SomeRootEntityTransactions>[];
  //     v.forEach((v) {
  //       arr0.add(SomeRootEntityTransactions.fromJson(v));
  //     });
  //     transactions = arr0;
  //   }
  //   createTime = json["createTime"]?.toString();
  // }

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
}
