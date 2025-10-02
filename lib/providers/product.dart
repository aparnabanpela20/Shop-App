import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.description,
    required this.id,
    required this.imageUrl,
    this.isFavorite = false,
    required this.price,
    required this.title,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
      'https://shop-app-30e51-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
    );
    try {
      final response = await http.patch(
        url,
        body: json.encode({'isFavorite': isFavorite}),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
        throw HttpException('Could not update favorite status.');
      }
    } catch (error) {
      _setFavValue(oldStatus);
      rethrow;
    }
  }
}
