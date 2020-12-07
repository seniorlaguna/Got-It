import 'package:equatable/equatable.dart';

final Set<String> categoryTags = {
  "eyes",
  "lips",
  "face",
  "skincare",
  "body_haircare",
  "nails",
  "tools"
};

final Set<String> tagRecommendations = {
  "white",
  "beige",
  "nude",
  "blush",
  "lila",
  "brown",
  "green",
  "red",
  "blue",
  "yellow",
  "black",
  "orange",
  "turquise",
  "pink",
  "eyeshadow powder",
  "eyeshadow liquid",
  "eyeshadow cream",
  "eyeshadow stick",
  "eyeshadow base",
  "eyeliner",
  "eyepencil",
  "kholliner",
  "lash primer",
  "mascara",
  "eyebrowpencil",
  "eyebrowpowder",
  "eyebrow gel color",
  "eyebrow gel transparent",
  "lipbalm",
  "lipgloss",
  "lip scrub",
  "lipstick",
  "liquid lipstick",
  "lip stain",
  "foundation liquid",
  "foundation powder",
  "foundation cream",
  "color correction",
  "concealer liquid",
  "concealer cream",
  "bronzer powder",
  "bronzer liquid",
  "bronzer cream",
  "blush powder",
  "blush liquid",
  "blush cream",
  "highlighter powder",
  "highlighter liquid",
  "highlighter cream",
  "setting powder",
  "setting spray",
  "moisturizer",
  "serum",
  "facemask",
  "peeling",
  "day cream",
  "night cream",
  "eyepads",
  "shampoo",
  "conditioner",
  "hairmask",
  "hair oil",
  "heat protection spray",
  "hairspray",
  "dry shampoo",
  "hair serum",
  "hair gel",
  "body scrub",
  "body lotion",
  "body cream",
  "body spray",
  "self tan",
  "body parfume",
  "shaving cream",
  "body wax",
  "body oil",
  "parfume",
  "nail polish",
  "shell lack",
  "dip powder",
  "nail polish remover",
  "hand cream",
  "lash curler",
  "brush",
  "sponge",
  "makeup wipes",
  "fake lashes",
};

final String favoriteTag = "favorite";
final String deleteTag = "delete";

class Product extends Equatable {
  static const TABLE_NAME = "Product";

  /// Sqlite database column names
  static const COLUMN_ID = "id";
  static const COLUMN_TITLE = "title";
  static const COLUMN_BARCODE = "barcode";
  static const COLUMN_IMAGE_PATH = "imagePath";
  static const COLUMN_TAGS = "tags";

  /// Tag seperator
  static const TAG_SEPERATOR = ";";

  // column types
  final int id;
  final String title;
  final String barcode;
  final String imagePath;
  final Set<String> tags;

  const Product(this.id, this.title, this.barcode, this.imagePath, this.tags);

  static Product empty() {
    return Product(null, null, null, null, Set<String>());
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(map[COLUMN_ID], map[COLUMN_TITLE], map[COLUMN_BARCODE],
        map[COLUMN_IMAGE_PATH], parseTags(map));
  }

  static Set<String> parseTags(Map<String, dynamic> map) {
    return (map[COLUMN_TAGS] as String).isEmpty
        ? Set<String>()
        : Set<String>.of((map[COLUMN_TAGS] as String).split(TAG_SEPERATOR)
          ..removeAt(0)
          ..removeLast());
  }

  static String stringifyTags(Set<String> tags) {
    // surrounds every tag with the tag seperator
    return "${Product.TAG_SEPERATOR}${tags.join(Product.TAG_SEPERATOR)}${Product.TAG_SEPERATOR}";
  }

  Product copyWith({
    int id,
    String title,
    String barcode,
    String imagePath,
    Set<String> tags,
  }) {
    return Product(id ?? this.id, title ?? this.title, barcode ?? this.barcode,
        imagePath ?? this.imagePath, tags ?? this.tags);
  }

  Map<String, dynamic> toMap() {
    return {
      Product.COLUMN_ID: id,
      Product.COLUMN_TITLE: title,
      Product.COLUMN_BARCODE: barcode,
      Product.COLUMN_IMAGE_PATH: imagePath,
      Product.COLUMN_TAGS: stringifyTags(tags)
    };
  }

  bool get like => tags.contains(favoriteTag);

  bool get delete => tags.contains(deleteTag);

  Set<String> get productTags => tags.difference({favoriteTag, deleteTag});

  @override
  List<Object> get props => [id, title, barcode, imagePath, tags];
}
