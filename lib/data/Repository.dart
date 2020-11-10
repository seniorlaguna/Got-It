import 'dart:async';

import 'package:got_it/data/ProductDatabase.dart';
import 'package:got_it/model/Product.dart';

class Repository {
  final ProductDatabase _productDatabase = ProductDatabase();

  Future<int> insertOrUpdate(Product product) async {
    // new product to save
    if (product.id == null) {
      return _productDatabase.insert(product);
    }
    // update product
    else {
      int affectedRows = await _productDatabase.update(product);
      assert(affectedRows == 1);

      return product.id;
    }
  }

  Future<List<Product>> getProductsBySearch(
      String titleRegex, Set<String> includedTags, Set<String> excludedTags) {
    return _productDatabase.search(
        titleRegex, includedTags.toList(), excludedTags.toList());
  }

  Future<int> delete(Product product) {
    product.tags.add(deleteTag);
    return insertOrUpdate(product);
  }

  Future<int> restore(Product product) {
    product.tags.remove(deleteTag);
    return insertOrUpdate(product);
  }

  Future<Product> getProductByBarcode(String barcode) async {
    List<Product> products =
        await _productDatabase.getProductsByBarcode(barcode);
    if (products.isEmpty) {
      return null;
    }
    return products.first;
  }

  Future<void> clearTrash() {
    return _productDatabase.clearTrash();
  }
}
