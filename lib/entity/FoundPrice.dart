class FoundPrice {
  num price;
  DateTime lastQueryTime;

  factory FoundPrice.fromJson(Map<String, dynamic> json) {
    return FoundPrice(
        json['price'],
        DateTime.fromMillisecondsSinceEpoch(json['lastQueryTime'])
    );
  }

  FoundPrice(this.price, this.lastQueryTime);

  @override
  String toString() {
    return 'FoundPrice{price: $price, lastQueryTime: $lastQueryTime}';
  }
}
