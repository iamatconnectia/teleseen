import 'dart:async';

import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../data/boxes.dart';
import '../../../services/index.dart';
import '../../entities/address.dart';
import '../../entities/shipping_method.dart';
import 'cart_mixin.dart';

mixin AddressMixin on CartMixin {
  Address? address;
  ShippingMethod? shippingMethod;
  double _shippingCost = 0.0;
  double get shippingCost => _shippingCost;
  void setShippingCost(double cost) {
    _shippingCost = cost;
    // Persist so it survives hot restarts
    UserBox().savedShippingCost = cost;
  }
  int? deliveryAreaId;
  String? deliveryAreaName;


  void saveShippingAddress(Address? address) {
    UserBox().shippingAddress = address;
  }

  Future<Address?> getShippingAddress() async {
    if (ServerConfig().isVendorManagerType()) {
      return null;
    }
    try {
      final address = UserBox().shippingAddress;
      if (address != null) {
        return address;
      } else {
        // final userJson = storage.getItem(kLocalKey['userInfo']!);
        final userInfo = UserBox().userInfo;

        if (userInfo != null) {
          var user = await Services().api.getUserInfo(userInfo.cookie);
          if (user != null) {
            user.isSocial = userInfo.isSocial;
          } else {
            user = userInfo;
          }

          if (user.billing == null) {
            final info = await Services().api.getCustomerInfo(user.id);
            if (info?['billing'] != null) {
              return info?['billing'];
            }
          }

          return Address(
            firstName:
                user.billing != null && user.billing!.firstName!.isNotEmpty
                    ? user.billing!.firstName
                    : user.firstName,
            lastName: user.billing != null && user.billing!.lastName!.isNotEmpty
                ? user.billing!.lastName
                : user.lastName,
            email: user.billing != null && user.billing!.email!.isNotEmpty
                ? user.billing!.email
                : user.email,
            street: user.billing != null && user.billing!.address1!.isNotEmpty
                ? user.billing!.address1
                : '',
            country: user.billing != null && isNotBlank(user.billing!.country)
                ? user.billing!.country
                : kPaymentConfig.defaultCountryISOCode,
            state: user.billing != null && user.billing!.state!.isNotEmpty
                ? user.billing!.state
                : kPaymentConfig.defaultStateISOCode,
            phoneNumber: user.billing != null && user.billing!.phone!.isNotEmpty
                ? user.billing!.phone
                : '',
            city: user.billing != null && user.billing!.city!.isNotEmpty
                ? user.billing!.city
                : '',
            zipCode: user.billing != null && user.billing!.postCode!.isNotEmpty
                ? user.billing!.postCode
                : '',
            apartment: user.billing != null && user.billing!.company!.isNotEmpty
                ? user.billing!.company
                : '',
            block: user.billing != null && user.billing!.address2!.isNotEmpty
                ? user.billing!.address2
                : '',
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void clearAddress() {
    address = null;
  }

  void setAddress(data) {
    address = data;
    saveShippingAddress(data);
  }

  Future<Address?> getAddress() async {
    address ??= await getShippingAddress();
    return address;
  }

  double? getShippingCost({bool includeTax = false}) {
    if (shippingMethod != null) {
      return (shippingMethod!.cost ?? 0) +
          (includeTax ? (shippingMethod!.shippingTax ?? 0) : 0);
    }
    if (shippingCost > 0) {
      return shippingCost;
    }
    return 0.0;
  }

  Future<void> setShippingMethod(ShippingMethod data) async {
    shippingMethod = data;
  }

  Future<void> getListCountries() async {
    final countries = await Services().api.getCountries();

    if (countries != null) {
      SettingsBox().countries = countries;
    }
  }
}
