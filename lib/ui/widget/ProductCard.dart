import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/model/Product.dart';

class ProductCard extends StatelessWidget {
  final Product _product;
  final Function _onTap;
  final LibraryView _libraryView;

  static final Image _defaultImage =
      Image.asset("assets/transparent_image.png");

  const ProductCard(this._product, this._onTap, this._libraryView, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
          tag: _product.id,

          // TODO: PERFORMANCE IMPROVEMENTS Clip

          child: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: FadeInImage(
                placeholder: _defaultImage.image,
                image: (_product.imagePath != null &&
                        File(_product.imagePath).existsSync())
                    ? Image.file(File(_product.imagePath)).image
                    : Image.asset("assets/default_product_image.jpg").image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ))),
      title: Text(_product.title, style: TextStyle(fontSize: 20)),
      subtitle: (_libraryView == LibraryView.Search && _product.delete)
          ? Text("#trash")
          : Text("#" +
              _product.productTags
                  .map((tag) => FlutterI18n.translate(context, tag))
                  .join(" #")),
      onTap: _onTap,
    );
  }
}
