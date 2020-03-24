import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/LibraryScreen.dart';
import 'package:got_it/ui/widget/ImageLoader.dart';

class FavoritesViewer extends LibraryScreen {

  static void start(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => FavoritesViewer()
    ));
  }

  @override
  Widget getAppBarContent(BuildContext context) {
    return ImageLoader(null, fallbackAsset: "assets/category_favorites.jpg");
  }

  @override
  String get appBarTitle => "category.favorites";

  @override
  DismissDirection get allowedDismissDirection => DismissDirection.endToStart;

  @override
  Widget get dismissibleBackground => Container(child: Icon(Icons.favorite_border),);

  @override
  Widget get dismissibleSecondBackground => null;

  @override
  LibraryEvent get initialEvent => LibraryOpened(null, null, Product.COLUMN_TITLE, true);

  @override
  LibraryView get libraryView => LibraryView.Favorites;

  @override
  void onDismissed(BuildContext context, DismissDirection dismissDirection, Product product, int index) {
    LibraryBloc bloc = BlocProvider.of<LibraryBloc>(context);
    bloc.add(LibraryProductDisliked(product));
  }

}