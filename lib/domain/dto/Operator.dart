import 'package:fishnet/domain/dto/PriceNumberPair.dart';

class Operator{

  PriceNumberPair priceNumberPair;
  String extraMessage;
  String failMessage;

  // 买入时间 （如果是卖出的话）
  DateTime buyDate;

  Operator._(this.priceNumberPair, this.extraMessage, this.failMessage, [this.buyDate]);

  bool isSuccess() {
    return priceNumberPair != null;
  }


  static Operator success(PriceNumberPair priceNumberPair, {extraMessage, buyDate}) {
    return Operator._(priceNumberPair, extraMessage, null, buyDate);
  }

  static Operator fail(String failMessage) {
    return Operator._(null, null, failMessage);
  }
}