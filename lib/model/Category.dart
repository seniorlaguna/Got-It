import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable{
  final int id;
  final String title;
  final IconData iconData;
  final String imagePath;
  final List<SubCategory> subCategories;

  @override
  List<Object> get props => [id, title, iconData, imagePath, subCategories];

  const Category(this.id, this.title, this.iconData, this.imagePath, this.subCategories);
}

class SubCategory extends Equatable {
  final int id;
  final String title;

  @override
  List<Object> get props => [id, title];

  const SubCategory(this.id, this.title);
}