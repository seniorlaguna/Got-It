import 'package:equatable/equatable.dart';

final Set<String> mainTags = {
  "main_tag.eyes",
  "main_tag.lips",
  "main_tag.skincare",
  "main_tag.body_haircare",
  "main_tag.nails",
  "main_tag.face",
  "main_tag.tools"
};

final Set<String> colorTags = {
  "tag.green",
  "tag.red",
  "tag.yellow",
  "tag.orange",
  "tag.blue",
  "tag.black",
  "tag.white"
};

final Set<String> brandTags = {
  "brand a",
  "brand b",
  "brand c",
  "brand d"
};

final Set<String> toolTags = {
  "tool a",
  "tool b",
  "tool c",
  "tool d"
};

final Set<String> allTags = Set<String>.of(mainTags.followedBy(colorTags).followedBy(brandTags).followedBy(toolTags));

final String favoriteTag = "favorite";
final String wishTag = "wish";
final String deleteTag = "delete";

class Product extends Equatable {

  static const TABLE_NAME = "Product";

  /// Sqlite database column names
  static const COLUMN_ID = "id";
  static const COLUMN_TITLE = "title";
  static const COLUMN_BARCODE = "barcode";
  static const COLUMN_IMAGE_PATH = "imagePath";
  static const COLUMN_TAGS = "tags";

  // column types
  final int id;
  final String title;
  final String barcode;
  final String imagePath;
  final Set<String> tags;

  const Product(
      this.id, this.title, this.barcode, this.imagePath, this.tags
      );

  static Product empty() {
    return Product(null, null, null, null,  Set<String>());
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
        map[COLUMN_ID],
        map[COLUMN_TITLE],
        map[COLUMN_BARCODE],
        map[COLUMN_IMAGE_PATH],
        (map[COLUMN_TAGS] as String).isEmpty ? Set<String>() : Set<String>.of((map[COLUMN_TAGS] as String).split(";"))
    );
  }

  Product copyWith({int id, String title, String barcode, String imagePath, Set<String> tags, bool favorite, bool wish, int toDelete}) {
    return Product(
        id ?? this.id,
        title ?? this.title,
        barcode ?? this.barcode,
        imagePath ?? this.imagePath,
        tags ?? this.tags
    );
  }

  bool get like => tags.contains(favoriteTag);

  bool get wish => tags.contains(wishTag);

  bool get delete => tags.contains(deleteTag);

  Set<String> get productTags => tags.difference(Set<String>.from([favoriteTag, wishTag, deleteTag]));

  @override
  List<Object> get props => [id, title, barcode, imagePath, tags];
}