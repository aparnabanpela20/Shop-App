import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './cart.dart';

class OrdersItem {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItem> products;

  OrdersItem({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  final List<OrdersItem> _orders = [];

  List<OrdersItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
      'https://shop-app-30e51-default-rtdb.firebaseio.com/orders.json',
    );
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map(
              (cp) => {
                'id': cp.id,
                'title': cp.title,
                'quantity': cp.quantity,
                'price': cp.price,
              },
            )
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrdersItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
