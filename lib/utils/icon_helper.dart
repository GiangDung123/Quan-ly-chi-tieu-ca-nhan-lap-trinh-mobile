import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'attach_money':
        return Icons.attach_money;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'work':
        return Icons.work;
      case 'payments':
        return Icons.payments;
      case 'savings':
        return Icons.savings;
      case 'category':
        return Icons.category;
      default:
        return Icons.account_balance_wallet;
    }
  }

  static String getIconName(IconData iconData) {
    if (iconData == Icons.restaurant) return 'restaurant';
    if (iconData == Icons.directions_bike) return 'directions_bike';
    if (iconData == Icons.school) return 'school';
    if (iconData == Icons.movie) return 'movie';
    if (iconData == Icons.attach_money) return 'attach_money';
    if (iconData == Icons.shopping_bag) return 'shopping_bag';
    if (iconData == Icons.home) return 'home';
    if (iconData == Icons.health_and_safety) return 'health_and_safety';
    if (iconData == Icons.card_giftcard) return 'card_giftcard';
    if (iconData == Icons.work) return 'work';
    if (iconData == Icons.payments) return 'payments';
    if (iconData == Icons.savings) return 'savings';
    if (iconData == Icons.category) return 'category';
    return 'account_balance_wallet';
  }
}
