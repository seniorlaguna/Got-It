import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/LibraryScreen.dart';
import 'package:got_it/ui/widget/ImageLoader.dart';

class TrashViewer extends LibraryScreen {

  static void start(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => TrashViewer()
    ));
  }

  @override
  // TODO: implement appBarTitle
  String get appBarTitle => "category.trash";

  @override
  Widget getAppBarContent(BuildContext context) {
    return ImageLoader(null, fallbackAsset: "assets/category_trash.jpg");
  }

  @override
  DismissDirection get allowedDismissDirection => DismissDirection.endToStart;

  @override
  Widget get dismissibleBackground => Container(color: Colors.green,
    child: Center(
        child: Icon(
            Icons.restore_from_trash,
          color: Colors.white,
        )
    )
  );

  @override
  Widget get dismissibleSecondBackground => null;

  @override
  LibraryEvent get initialEvent => LibraryOpened(null, null, Product.COLUMN_TITLE, true);

  @override
  LibraryView get libraryView => LibraryView.Trash;

  @override
  void onDismissed(BuildContext context, DismissDirection dismissDirection, Product product, int index) {
    LibraryBloc bloc = BlocProvider.of<LibraryBloc>(context);
    bloc.add(LibraryProductRecovered(product, index));
  }

}