import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += (item["price"] as double) * (item["qty"] as int);
    }
    return total;
  }

  void addToCart(String title, double price, String imagePath) {
    final index = _cartItems.indexWhere((item) => item["title"] == title);
    if (index != -1) {
      _cartItems[index]["qty"] += 1;
    } else {
      _cartItems.add({
        "title": title,
        "price": price,
        "image": imagePath,
        "qty": 1,
      });
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
