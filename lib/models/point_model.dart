import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../common/extensions/num_ext.dart';
import '../services/index.dart';
import 'cart/cart_base.dart';
import 'entities/point.dart';

class PointModel extends ChangeNotifier {
  final Services _service = Services();
  Point? point;
  int? cartPointsRate, maxPointDiscount;
  double? cartPriceRate, maxPriceDiscount;

  bool get isAvailableReward =>
      point != null &&
      cartPointsRate != null &&
      cartPointsRate! > 0 &&
      cartPriceRate != null &&
      cartPriceRate! > 0 &&
      point?.maxPointDiscount != null;

  Future<void> getMyPoint(String? token) async {
    try {
      if (token == null || token.isEmpty) {
        return;
      }
      point = await _service.api.getMyPoint(token);
      if (point != null) {
        cartPointsRate = point?.cartPointsRate ?? 0;
        cartPriceRate = point?.cartPriceRate?.toDouble() ?? 0.0;
      }
    } catch (err) {
      printLog('getMyPoint $err');
    }
    notifyListeners();
  }

  double getMaxPointsDiscount(double totalBill) {
    if (isAvailableReward == false) {
      return 0;
      }

    final maxPointDiscount = point?.maxPointDiscount ?? '0';

    if (maxPointDiscount.contains('%')) {
      var percentDiscount =
          double.tryParse(maxPointDiscount.replaceAll('%', '')) ?? 0;
      final rate = (cartPriceRate ?? 0.0) == 0.0 ? 1.0 : (cartPriceRate ?? 1.0);
      final pRate = (cartPointsRate ?? 0) == 0 ? 1 : (cartPointsRate ?? 1);
      return percentDiscount *
          totalBill /
          100 *
          pRate /
          rate;
    }

    return double.tryParse(maxPointDiscount) ?? 0;
  }

  void updateRewardDiscount(CartModel cartModel) {
    final subTotal = cartModel.getSubTotal() ?? 0;

    final pRate = (cartPointsRate ?? 0) == 0 ? 1 : (cartPointsRate ?? 1);
    final rate = (cartPriceRate ?? 0.0) == 0.0 ? 1.0 : (cartPriceRate ?? 1.0);

    if (cartPointsRate != null && cartPointsRate! > 0 && cartPriceRate != null) {
      maxPriceDiscount =
          getMaxPointsDiscount(subTotal) * rate / pRate;
      maxPointDiscount = getMaxPointsDiscount(subTotal).ceil();
    }
  }

  double totalReward(double appliedPoints) {
    var total = 0.0;
    if (isAvailableReward == false) {
      return 0;
    }

    final pRate = (cartPointsRate ?? 0) == 0 ? 1 : (cartPointsRate ?? 1);
    final rate = (cartPriceRate ?? 0.0) == 0.0 ? 1.0 : (cartPriceRate ?? 1.0);

    if ((maxPointDiscount ?? 0).ceil() == appliedPoints.toDouble()) {
      total = maxPriceDiscount ?? 0;
    } else {
      total = appliedPoints * rate / pRate;
    }

    return total;
  }
}
