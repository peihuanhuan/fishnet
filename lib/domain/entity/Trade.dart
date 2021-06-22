class Trade {
  int id;

  // 交易价格
  num price;

  // 交易数量
  int number;

  // 交易时间
  DateTime time;


  num getAmount() {
    return price * number;
  }

  Trade(this.id, this.price, this.number, this.time);

  Map<String, dynamic> toJson() => {
        'id': id,
        'price': price,
        'number': number,
        'time': time.millisecondsSinceEpoch
      };

  factory Trade.fromJson(Map<String, dynamic> json) {
    if(json == null || json.isEmpty) {
      return null;
    }
    return Trade(json['id'], json['price'], json['number'], DateTime.fromMillisecondsSinceEpoch(json['time']));
  }
}
