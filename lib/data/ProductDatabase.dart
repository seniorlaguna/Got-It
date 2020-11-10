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
      " `${Product.COLUMN_TAGS}` TEXT,"
      " PRIMARY KEY(`${Product.COLUMN_ID}`) )";

  Future<Database> database;

  ProductDatabase() {
    database = openDatabase(DB_NAME, onCreate: onCreateDatabase, version: 1);
  }

  void onCreateDatabase(Database database, int version) {
    database.execute(SQL_CREATE_TABLE_PRODUCT);
  }

  Future<int> insert(Product product) async {
    return (await database).insert(Product.TABLE_NAME, {
      Product.COLUMN_TITLE: product.title,
      Product.COLUMN_BARCODE: product.barcode,
      Product.COLUMN_IMAGE_PATH: product.imagePath,
      Product.COLUMN_TAGS: product.tags.join(";")
    });
  }

  Future<int> update(Product product) async {
    return (await database).update(
        Product.TABLE_NAME,
        {
          Product.COLUMN_TITLE: product.title,
          Product.COLUMN_BARCODE: product.barcode,
          Product.COLUMN_IMAGE_PATH: product.imagePath,
          Product.COLUMN_TAGS: product.tags.join(";")
        },
        where: "`${Product.COLUMN_ID}` = ?",
        whereArgs: [product.id]);
  }

  Future<List<Product>> search(String titleRegex, List<String> includedTags,
      List<String> excludedTags) async {
    List<String> includedTagsWhere = includedTags
        .map((String tag) => "tags LIKE ('%' || '$tag' || '%')")
        .toList();
    String includedTagsWhereSql = includedTagsWhere.join(" AND ");

    List<String> excludedTagsWhere = excludedTags
        .map((String tag) => "tags NOT LIKE ('%' || '$tag' || '%')")
        .toList();
    String excludedTagsWhereSql = excludedTagsWhere.join(" AND ");

    String sql = "SELECT * FROM Product WHERE title LIKE ('%' || ? || '%')";

    if (includedTagsWhereSql.isNotEmpty) {
      sql += "AND $includedTagsWhereSql";
    }

    if (excludedTagsWhereSql.isNotEmpty) {
      sql += "AND $excludedTagsWhereSql";
    }

    sql += " ORDER BY title COLLATE NOCASE";

    return (await (await database).rawQuery(sql, [titleRegex]))
        .map((Map<String, dynamic> map) => Product.fromMap(map))
        .toList();
  }

  Future<List<Product>> getProductsByBarcode(String barcode) async {
    return (await (await database).query(Product.TABLE_NAME,
            where: "barcode = ?", whereArgs: [barcode]))
        .map((Map<String, dynamic> map) => Product.fromMap(map))
        .toList();
  }

  Future<void> clearTrash() async {
    return (await database).delete(Product.TABLE_NAME,
        where: "${Product.COLUMN_TAGS} LIKE '%' || ? || '%'",
        whereArgs: [deleteTag]);
  }
}
