import 'package:fishnet/domain/dto/PriceNumberPair.dart';

class Operator{

  PriceNumberPair priceNumberPair;
  String extraMessage;
  String failMessage;

  Operator._(this.priceNumberPair, this.extraMessage, this.failMessage);

  bool isSuccess() {
    return priceNumberPair != null;
  }


  static Operator success(PriceNumberPair priceNumberPair, {extraMessage}) {
    return Operator._(priceNumberPair, extraMessage, null);
  }

  static Operator fail(String failMessage) {
    return Operator._(null, null, failMessage);
  }
}