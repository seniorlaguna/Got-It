import 'package:got_it/data/ProductDatabase.dart';
import 'package:got_it/model/Category.dart';
import 'package:got_it/model/Product.dart';

class Repository {

  final ProductDatabase _productDatabase = ProductDatabase();

  Future<int> insert(Product product) => _productDatabase.insert(product);

  void update(Product product) => _productDatabase.update(product);

  void delete(Product product) => _productDatabase.deleteById(product.id);

  void deleteFromWishList(String barcode) async {
    Product p = await _productDatabase.getProductByBarcode(barcode);
    if (p != null && p.wish) {
      _productDatabase.deleteById(p.id);
    }
  }

  void recover(Product product) => _productDatabase.recoverById(product.id);

  Future<Product> getProductById(int id) {
    return _productDatabase.getProductById(id);
  }

  Future<List<Product>> getAllProducts(String orderBy, bool ascending) {
    return _productDatabase.getAllProducts(orderBy, ascending);
  }

  Future<List<Product>> getProductsByCategory(Category category, SubCategory subCategory, String order, bool ascending) async {

    return _productDatabase.getProductsByCategory(category.id, subCategory == null ? null : subCategory.id, order, ascending);
  }

  Future<List<Product>> getProductsFromWishList(String order, bool ascending) async {
    return _productDatabase.getProductsFromWishList(order, ascending);
  }

  Future<List<Product>> getProductsFromTrash(String order, bool ascending) async {
    return _productDatabase.getProductsFromTrash(order, ascending);
  }

  Future<List<Product>> getProductsFromFavorites(String order, bool ascending) async {
    return _productDatabase.getProductsFromFavorites(order, ascending);
  }

  Future<bool> exists(String barcode) async {
    Product p = await _productDatabase.getProductByBarcode(barcode);
    return p != null;
  }

  Future<bool> inLibrary(String barcode) async {
    Product p = await _productDatabase.getProductByBarcode(barcode);
    return (p != null && p.toDelete == null && !p.wish);
  }

  Future<bool> inWishList(String barcode) async {
    Product p = await _productDatabase.getProductByBarcode(barcode);
    return (p != null && p.toDelete == null && p.wish);
  }

  void like(Product product, bool favorite) => _productDatabase.update(product.copyWith(favorite: favorite));

}