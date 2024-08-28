import 'package:flutter/cupertino.dart';

import '../models/product.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  final DatabaseService _dbService = DatabaseService();
 // String? _selectedCategory;

  List<Product> get items {
    return [..._items];
  }

  late List<Product> _filteredItems = [];

  List<Product> get filteredItems {
    if (_filteredItems.isEmpty) {
      return [..._items];
    }
    return [..._filteredItems];
  }

  Future<void> fetchAndSetProducts() async {
    final dataList = await _dbService.getProducts();
    _items = dataList;
    notifyListeners();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    await _dbService.insertProduct(product);
    _items.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      await _dbService.updateProduct(newProduct);
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    await _dbService.deleteProduct(id);
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }

 /* void filterByCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategory = null;
    notifyListeners();
  }*/

  void filterProducts(String query) {
    if (query.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = _items.where((product) {
        final productName = product.name.toLowerCase();
        final productPrice = product.price.toString().toLowerCase();
        final productCategory = product.category.toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return productName.contains(searchQuery) || productPrice.contains(searchQuery) || productCategory.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }

}
