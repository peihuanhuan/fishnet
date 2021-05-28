class FoundPrice {
  String code;
  num price;
  DateTime lastQueryTime;

  factory FoundPrice.fromJson(Map<String, dynamic> json) {
    return FoundPrice(
        json['code'],
        json['price'],
        DateTime.fromMillisecondsSinceEpoch(json['lastQueryTime'])
    );
  }

  FoundPrice(this.code, this.price, this.lastQueryTime);

  @override
  String toString() {
    return 'FoundPrice{code: $code, price: $price, lastQueryTime: $lastQueryTime}';
  }
}
