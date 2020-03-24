import 'package:sqflite/sqflite.dart';

import '../model/Product.dart';

class ProductDatabase {

  static const String DB_NAME = "got_it.db";
  static const String SQL_CREATE_TABLE_PRODUCT =
      "CREATE TABLE `${Product.TABLE_NAME}` "
      "( `${Product.COLUMN_ID}` INTEGER,"
      " `${Product.COLUMN_TITLE}` TEXT,"
      " `${Product.COLUMN_BARCODE}` TEXT,"
      " `${Product.COLUMN_IMAGE_PATH}` TEXT,"
      " `${Product.COLUMN_CATEGORY}` INTEGER,"
      " `${Product.COLUMN_SUB_CATEGORY}` INTEGER,"
      " `${Product.COLUMN_NOTES}` TEXT,"
      " `${Product.COLUMN_FAVORITES}` INTEGER,"
      " `${Product.COLUMN_WISH}` INTEGER,"
      " `${Product.COLUMN_TO_DELETE}` INTEGER,"
      " PRIMARY KEY(`${Product.COLUMN_ID}`) )";

  static const String SQL_DELETE_PRODUCTS = "DELETE FROM ${Product.TABLE_NAME} WHERE ${Product.COLUMN_TO_DELETE} < ?";
  static const int DAYS_TO_DELETE = 7;

  Future<Database> database;

  ProductDatabase() {
    database = openDatabase(
        DB_NAME,
        onCreate: onCreateDatabase,
        onOpen: deleteOldProducts,
        version: 1
    );
  }

  void deleteOldProducts(Database database) {
    int timestamp = DateTime.now().subtract(Duration(days: DAYS_TO_DELETE)).millisecondsSinceEpoch;

    database.delete(
        Product.TABLE_NAME,
        where: "${Product.COLUMN_TO_DELETE} < ?",
        whereArgs: [timestamp]
    );
  }

  void onCreateDatabase(Database database, int version) {
    database.execute(SQL_CREATE_TABLE_PRODUCT);
  }

  Future<int> insert(Product product) async {
    return (await database).insert(
        Product.TABLE_NAME,
        {
          Product.COLUMN_TITLE : product.title,
          Product.COLUMN_BARCODE : product.barcode,
          Product.COLUMN_IMAGE_PATH : product.imagePath,
          Product.COLUMN_CATEGORY : product.category.id,
          Product.COLUMN_SUB_CATEGORY : product.subCategory.id,
          Product.COLUMN_NOTES : product.notes,
          Product.COLUMN_WISH : product.wish,
          Product.COLUMN_TO_DELETE : product.toDelete,
        }
    );
  }

  void update(Product product) async {
    (await database).update(
        Product.TABLE_NAME,
        {
          Product.COLUMN_TITLE : product.title,
          Product.COLUMN_BARCODE : product.barcode,
          Product.COLUMN_IMAGE_PATH : product.imagePath,
          Product.COLUMN_CATEGORY : product.category.id,
          Product.COLUMN_SUB_CATEGORY : product.subCategory.id,
          Product.COLUMN_NOTES : product.notes,
          Product.COLUMN_FAVORITES : product.favorite,
          Product.COLUMN_WISH : product.wish,
          Product.COLUMN_TO_DELETE : product.toDelete,
        },
        where: "`${Product.COLUMN_ID}` = ?",
        whereArgs: [product.id]
    );
  }

  void deleteById(int id) async {
    (await database).update(
        Product.TABLE_NAME,
        {
          Product.COLUMN_TO_DELETE : DateTime.now().millisecondsSinceEpoch
        },
        where: "`${Product.COLUMN_ID}` = ?",
        whereArgs: [id]
    );
  }

  void recoverById(int id) async {
    (await database).update(
        Product.TABLE_NAME,
        {
          Product.COLUMN_TO_DELETE : null
        },
        where: "`${Product.COLUMN_ID}` = ?",
        whereArgs: [id]
    );
  }

  Future<Product> getProductById(int id) async {
    List<Product> products = (await (await database).query(
        Product.TABLE_NAME
    )).map((Map<String, dynamic> map) => Product.fromMap(map)).toList();

    return products.length == 0 ? null : products[0];
  }

  Future<List<Product>> getAllProducts(String order, bool ascending) async {
    String orderBy = ascending ? "`$order` ASC" : "`$order` DESC";

    return (await (await database).query(
        Product.TABLE_NAME,
        where: "`${Product.COLUMN_TO_DELETE}` IS NULL",
        orderBy: orderBy
    )).map((Map<String, dynamic> map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsByCategory(int category, int subCategory, String order, bool ascending) async {
    String orderBy = ascending ? "`$order` ASC" : "`$order` DESC";
    String where = (subCategory == null) ?
    "`${Product.COLUMN_CATEGORY}` = ? AND `${Product.COLUMN_TO_DELETE}` IS NULL" :
    "`${Product.COLUMN_CATEGORY}` = ? AND `${Product.COLUMN_SUB_CATEGORY}` = ? AND `${Product.COLUMN_TO_DELETE}` IS NULL";
    List<dynamic> whereArgs = (subCategory == null) ? [category] : [category, subCategory];

    return (await (await database).query(
        Product.TABLE_NAME,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy
    )).map((Map<String, dynamic> map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsFromWishList(String order, bool ascending) async {
    String orderBy = ascending ? "`$order` ASC" : "`$order` DESC";

    return (await (await database).query(
      Product.TABLE_NAME,
      where: "`${Product.COLUMN_WISH}` = 1 AND `${Product.COLUMN_TO_DELETE}` IS NULL",
      orderBy: orderBy,
    )).map((Map<String, dynamic> map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsFromTrash(String order, bool ascending) async {
    String orderBy = ascending ? "`$order` ASC" : "`$order` DESC";

    return (await (await database).query(
      Product.TABLE_NAME,
      where: "`${Product.COLUMN_TO_DELETE}` IS NOT NULL",
      orderBy: orderBy,
    )).map((Map<String, dynamic> map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsFromFavorites(String order, bool ascending) async {
    String orderBy = ascending ? "`$order` ASC" : "`$order` DESC";

    return (await (await database).query(
      Product.TABLE_NAME,
      where: "`${Product.COLUMN_FAVORITES}` = 1 AND `${Product.COLUMN_TO_DELETE}` IS NULL",
      orderBy: orderBy,
    )).map((Map<String, dynamic> map) => Product.fromMap(map)).toList();
  }

  Future<Product> getProductByBarcode(String barcode) async {
  List<Product> products = (await (await database).query(
    Product.TABLE_NAME,
    where: "`${Product.COLUMN_BARCODE}` = ?",
    whereArgs: [barcode]
  )).map((Map<String, dynamic> map) => Product.fromMap(map)).toList();

  return products.isEmpty ? null : products[0];
  }

}