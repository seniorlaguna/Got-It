import 'package:equatable/equatable.dart';
import 'package:got_it/data/Categories.dart';
import 'package:got_it/model/Category.dart';

class Product extends Equatable {

  static const TABLE_NAME = "Product";

  /// Sqlite database column names
  static const COLUMN_ID = "id";
  static const COLUMN_TITLE = "title";
  static const COLUMN_BARCODE = "barcode";
  static const COLUMN_IMAGE_PATH = "imagePath";
  static const COLUMN_CATEGORY = "category";
  static const COLUMN_SUB_CATEGORY = "subCategory";
  static const COLUMN_NOTES = "notes";
  static const COLUMN_FAVORITES = "favorite";
  static const COLUMN_WISH = "wish";
  static const COLUMN_TO_DELETE = "toDelete";

  // column types
  final int id;
  final String title;
  final String barcode;
  final String imagePath;
  final Category category;
  final SubCategory subCategory;
  final String notes;
  final bool favorite;
  final bool wish;
  final int toDelete;

  const Product(
      this.id, this.title, this.barcode, this.imagePath,
      this.category, this.subCategory, this.notes,
      this.favorite, this.wish, {this.toDelete}
      );

  static Product empty() {
    return Product(0, "", "", "", null, null, "", false, false, toDelete: null);
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
        map[COLUMN_ID],
        map[COLUMN_TITLE],
        map[COLUMN_BARCODE],
        map[COLUMN_IMAGE_PATH],
        categoryById(map[COLUMN_CATEGORY]),
        subCategoryById(map[COLUMN_CATEGORY], map[COLUMN_SUB_CATEGORY]),
        map[COLUMN_NOTES],
        map[COLUMN_FAVORITES] == 1,
        map[COLUMN_WISH] == 1,
        toDelete: map[COLUMN_TO_DELETE]
    );
  }

  Product copyWith({int id, String title, String barcode, String imagePath, Category category, SubCategory subCategory, String notes, bool favorite, bool wish, int toDelete}) {
    return Product(
        id ?? this.id,
        title ?? this.title,
        barcode ?? this.barcode,
        imagePath ?? this.imagePath,
        category ?? this.category,
        subCategory ?? this.subCategory,
        notes ?? this.notes,
        favorite ?? this.favorite,
        wish ?? this.wish,
        toDelete : toDelete ?? this.toDelete
    );
  }

  @override
  List<Object> get props => [id, title, barcode, imagePath, category, subCategory, notes, favorite, wish, toDelete];
}