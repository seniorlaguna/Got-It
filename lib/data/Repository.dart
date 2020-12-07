import 'dart:async';

import 'package:got_it/data/ProductDatabase.dart';
import 'package:got_it/model/Product.dart';

class Repository {
  final ProductDatabase _productDatabase = ProductDatabase();

  Future<int> insertOrUpdate(Product product) async {
    // new product to save
    if (product.id == null) {
      return _productDatabase.insert(product.toMap());
    }
    // update product
    else {
      int affectedRows = await _productDatabase.update(product.toMap());
      assert(affectedRows == 1);

      return product.id;
    }
  }

  Future<List<Product>> getProductsBySearch(String titleRegex,
      Set<String> includedTags, Set<String> excludedTags) async {
    return (await _productDatabase.search(
            titleRegex, includedTags, excludedTags))
        .map((e) => Product.fromMap(e))
        .toList();
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
    Iterable<Product> products =
        await _productDatabase.getProductsByBarcode(barcode);
    if (products.isEmpty) {
      return null;
    }
    return products.first;
  }

  Future<void> clearTrash() {
    return _productDatabase.clearTrash();
  }

  Future<List<String>> getTagsRanking(Set<String> includedTags) async {
    List<Map<String, dynamic>> productTags =
        await _productDatabase.search("", includedTags, {}, tagsOnly: true);

    List<Iterable<String>> tags = productTags.map((e) {
      return (Product.parseTags(e)..remove(deleteTag)..remove(favoriteTag));
    }).toList();

    return _ranking(tags);
  }

  List<String> _ranking<T>(List<Iterable<String>> matrix) {
    Map<String, int> d = {};

    for (var list in matrix) {
      for (var tag in list) {
        if (d.containsKey(tag)) {
          d[tag]++;
        } else {
          d[tag] = 1;
        }
      }
    }

    return d.keys.toList()..sort((a, b) => d[b] - d[a]);
  }
}
