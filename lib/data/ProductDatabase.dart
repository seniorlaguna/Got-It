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

  Future<int> insert(Map<String, dynamic> product) async {
    return (await database).insert(Product.TABLE_NAME, product);
  }

  Future<int> update(Map<String, dynamic> product) async {
    return (await database).update(Product.TABLE_NAME, product,
        where: "`${Product.COLUMN_ID}` = ?",
        whereArgs: [product[Product.COLUMN_ID]]);
  }

  Future<List<Map<String, dynamic>>> search(
      String titleRegex, Set<String> includedTags, Set<String> excludedTags,
      {bool tagsOnly = false}) async {
    Iterable<String> includedTagsWhere = includedTags.map((String tag) =>
        "tags LIKE ('%${Product.TAG_SEPERATOR}' || '$tag' || '${Product.TAG_SEPERATOR}%')");
    String includedTagsWhereSql = includedTagsWhere.join(" AND ");

    Iterable<String> excludedTagsWhere = excludedTags
        .map((String tag) =>
            "tags NOT LIKE ('%${Product.TAG_SEPERATOR}' || '$tag' || '${Product.TAG_SEPERATOR}%')")
        .toSet();
    String excludedTagsWhereSql = excludedTagsWhere.join(" AND ");

    String sql =
        "SELECT ${tagsOnly ? Product.COLUMN_TAGS : "*"} FROM Product WHERE title LIKE ('%' || ? || '%')";

    if (includedTagsWhereSql.isNotEmpty) {
      sql += "AND $includedTagsWhereSql";
    }

    if (excludedTagsWhereSql.isNotEmpty) {
      sql += "AND $excludedTagsWhereSql";
    }

    sql += " ORDER BY title COLLATE NOCASE";

    return (await (await database).rawQuery(sql, [titleRegex]));
  }

  Future<Iterable<Product>> getProductsByBarcode(String barcode) async {
    return (await (await database).query(Product.TABLE_NAME,
            where: "barcode = ?", whereArgs: [barcode]))
        .map((Map<String, dynamic> map) => Product.fromMap(map));
  }

  Future<void> clearTrash() async {
    return (await database).delete(Product.TABLE_NAME,
        where:
            "${Product.COLUMN_TAGS} LIKE '%${Product.TAG_SEPERATOR}' || ? || '${Product.TAG_SEPERATOR}%'",
        whereArgs: [deleteTag]);
  }
}
