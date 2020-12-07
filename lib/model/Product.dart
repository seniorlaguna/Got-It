import 'package:equatable/equatable.dart';

final Set<String> mainTags = {
  "main_tag.eyes",
  "main_tag.lips",
  "main_tag.face",
  "main_tag.skincare",
  "main_tag.body_haircare",
  "main_tag.nails",
  "main_tag.tools"
};

final Set<String> colorTags = {
  "tag.white",
  "tag.beige",
  "tag.nude",
  "tag.blush",
  "tag.lila",
  "tag.brown",
  "tag.green",
  "tag.red",
  "tag.blue",
  "tag.yellow",
  "tag.black",
  "tag.orange",
  "tag.turquise",
  "tag.pink",
};

final Map<String, Set<String>> toolTags = {
  "main_tag.eyes": {
    "tag.eyeshadow_powder",
    "tag.eyeshadow_liquid",
    "tag.eyeshadow_cream",
    "tag.eyeshadow_stick",
    "tag.eyeshadow_base",
    "tag.eyeliner",
    "tag.eyepencil",
    "tag.kholliner",
    "tag.lash_primer",
    "tag.mascara",
    "tag.eyebrowpencil",
    "tag.eyebrowpowder",
    "tag.eyebrow_gel_color",
    "tag.eyebrow_gel_transparent",
  },
  "main_tag.lips": {
    "tag.lipbalm",
    "tag.lipgloss",
    "tag.lip_scrub",
    "tag.lipstick",
    "tag.liquid_lipstick",
    "tag.lip_stain"
  },
  "main_tag.face": {
    "tag.foundation_liquid",
    "tag.foundation_powder",
    "tag.foundation_cream",
    "tag.color_correction",
    "tag.concealer_liquid",
    "tag.concealer_cream",
    "tag.bronzer_powder",
    "tag.bronzer_liquid",
    "tag.bronzer_cream",
    "tag.blush_powder",
    "tag.blush_liquid",
    "tag.blush_cream",
    "tag.highlighter_powder",
    "tag.highlighter_liquid",
    "tag.highlighter_cream",
    "tag.setting_powder",
    "tag.setting_spray",
  },
  "main_tag.skincare": {
    "tag.moisturizer",
    "tag.serum",
    "tag.facemask",
    "tag.peeling",
    "tag.day_cream",
    "tag.night_cream",
    "tag.eyepads",
  },
  "main_tag.body_haircare": {
    "tag.shampoo",
    "tag.conditioner",
    "tag.hairmask",
    "tag.hair_oil",
    "tag.heat_protection_spray",
    "tag.hairspray",
    "tag.dry_shampoo",
    "tag.hair_serum",
    "tag.hair_gel",
    "tag.body_scrub",
    "tag.body_lotion",
    "tag.body_cream",
    "tag.body_spray",
    "tag.self_tan",
    "tag.body_parfume",
    "tag.shaving_cream",
    "tag.body_wax",
    "tag.body_oil",
    "tag.parfume",
  },
  "main_tag.nails": {
    "tag.nail_polish",
    "tag.shell_lack",
    "tag.dip_powder",
    "tag.nail_polish_remover",
    "tag.hand_cream",
  },
  "main_tag.tools": {
    "tag.lash_curler",
    "tag.brush",
    "tag.sponge",
    "tag.makeup_wipes",
    "tag.fake_lashes",
  }
};

//final Set<String> allTags = Set<String>.of(mainTags.followedBy(colorTags).followedBy(toolTags));

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
        : Set<String>.of((map[COLUMN_TAGS] as String).split(TAG_SEPERATOR));
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
      Product.COLUMN_TAGS: tags.join(TAG_SEPERATOR)
    };
  }

  bool get like => tags.contains(favoriteTag);

  bool get wish => tags.contains(wishTag);

  bool get delete => tags.contains(deleteTag);

  Set<String> get productTags =>
      tags.difference({favoriteTag, wishTag, deleteTag});

  @override
  List<Object> get props => [id, title, barcode, imagePath, tags];
}
