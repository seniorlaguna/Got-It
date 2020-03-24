import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/dismissible.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/LibraryScreen.dart';

class WishListViewer extends LibraryScreen {

  static void start(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => WishListViewer()
    ));
  }

  @override
  DismissDirection get allowedDismissDirection => DismissDirection.endToStart;

  @override
  Widget get dismissibleBackground => Container(child: Center(child: Icon(Icons.done),),);

  @override
  Widget get dismissibleSecondBackground => null;

  @override
  LibraryEvent get initialEvent => LibraryOpened(null, null, Product.COLUMN_TITLE, true);

  @override
  LibraryView get libraryView => LibraryView.WishList;

  @override
  void onDismissed(BuildContext context, DismissDirection dismissDirection, Product product, int index) {
    LibraryBloc bloc = BlocProvider.of<LibraryBloc>(context);
    bloc.add(LibraryProductAddedToLibrary(product));
  }

}