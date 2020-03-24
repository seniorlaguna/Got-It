import 'package:flutter/material.dart';
import 'package:got_it/model/Category.dart';

const List<Category> Categories = [
  const Category(
    1,
    "category.eyes",
    Icons.remove_red_eye,
    "assets/category_eyes.jpg",
    [
      const SubCategory(
        1,
        "Wimpern"
      ),
      const SubCategory(
          2,
          "Sonstiges"
      )


    ]
  ),
  const Category(
      2,
      "category.face",
      Icons.face,
      "assets/category_face.jpg",
      [
        const SubCategory(
            1,
            "Cremes"
        ),
        const SubCategory(
            2,
            "Lotion"
        ),
        const SubCategory(
            3,
            "Maske"
        )


      ]
  ),
  const Category(
      3,
      "category.nails",
      Icons.signal_cellular_4_bar,
      "assets/category_nails.jpg",
      [
        const SubCategory(
            1,
            "Sonstiges"
        )


      ]
  ),
  const Category(
      4,
      "category.body",
      Icons.person,
      "assets/category_body.jpg",
      [
        const SubCategory(
            1,
            "Cremes"
        ),
        const SubCategory(
            2,
            "Lotion"
        ),
        const SubCategory(
            3,
            "Maske"
        )


      ]
  ),

  const Category(
      5,
      "category.lips",
      Icons.whatshot,
      "assets/category_lips.jpg",
      [
        const SubCategory(
            1,
            "Cremes"
        ),
        const SubCategory(
            2,
            "Lotion"
        ),
        const SubCategory(
            3,
            "Maske"
        )


      ]
  )
];

Category categoryById(int id) {
  for (Category category in Categories) {
    if (category.id == id) return category;
  }
  return null;
}

SubCategory subCategoryById(int categoryId, int subCategoryId) {

  Category category = categoryById(categoryId);
  if (category == null) return null;

  for (SubCategory subCategory in category.subCategories) {
    if (subCategory.id == subCategoryId) return subCategory;
  }

  return null;

}