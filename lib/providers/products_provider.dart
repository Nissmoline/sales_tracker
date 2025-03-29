import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  // upload JSON (assets/products.json)
  Future<void> loadProducts() async {
    try {
      final jsonString =
          await rootBundle.loadString('lib/assets/products.json');
      final jsonList = json.decode(jsonString) as List;
      _products = jsonList.map((p) => Product.fromJson(p)).toList();
      notifyListeners();
    } catch (e) {
      // if JSON not find
      debugPrint('Error loading products: $e');
    }
  }
}
