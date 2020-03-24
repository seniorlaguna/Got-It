import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/model/Category.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/LibraryScreen.dart';
import 'package:got_it/ui/widget/ImageLoader.dart';
import 'package:got_it/ui/widget/ProductCard.dart';

class CategoryViewer extends LibraryScreen {

  final Category _category;

  CategoryViewer(this._category);

  static void start(BuildContext context, Category category) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CategoryViewer(category)
    ));
  }

  @override
  DismissDirection get allowedDismissDirection => DismissDirection.endToStart;

  @override
  LibraryEvent get initialEvent => LibraryOpened(_category, null, Product.COLUMN_TITLE, true);

  @override
  LibraryView get libraryView => LibraryView.Category;

  @override
  Widget get dismissibleBackground => Container(
    color: Colors.red,
    child: Center(
      child: Icon(Icons.delete, color: Colors.white),
    ),
  );

  @override
  Widget get dismissibleSecondBackground => null;

  @override
  String get appBarTitle => _category.title;

  @override
  Widget getAppBarContent(BuildContext context) {
    return ImageLoader(null, fallbackAsset: _category.imagePath);
  }

  Widget getFilterBar(BuildContext context) {
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          getFilterButton(context),
          getOrderByButton(context),
          getAscendingButton(context)
        ],
      ),
    );
  }

  Widget getFilterButton(BuildContext context) {
    LibraryBloc bloc = BlocProvider.of<LibraryBloc>(context);

    return DropdownButton<SubCategory>(
      hint: Text("Unterkategorie"),
        value: (bloc.state as LibraryLoaded).subCategory,
        items: _category.subCategories.map((SubCategory subCategory) {
          return DropdownMenuItem(child: Text(subCategory.title), value: subCategory);
        }).toList()..add(
          DropdownMenuItem(
            child: Text("Ungefiltert", style: TextStyle(fontWeight: FontWeight.w600),), value: null,
          )
        ),

        onChanged: (SubCategory subCategory) {
          bloc.add(LibraryOpened(_category, subCategory, (bloc.state as LibraryLoaded).orderBy, (bloc.state as LibraryLoaded).ascending));
        }
    );
  }
  
  Widget getOrderByButton(BuildContext context) {
    LibraryBloc bloc = BlocProvider.of<LibraryBloc>(context);

    return DropdownButton<String>(
      value: (bloc.state as LibraryLoaded).orderBy,
        items: [
          DropdownMenuItem(child: Text(Product.COLUMN_TITLE), value: Product.COLUMN_TITLE,)
        ],

        onChanged: (String orderBy) {
          bloc.add(LibraryOpened(_category, (bloc.state as LibraryLoaded).subCategory, orderBy, (bloc.state as LibraryLoaded).ascending));
        }
    );
  }

  Widget getAscendingButton(BuildContext context) {
    LibraryBloc bloc = BlocProvider.of<LibraryBloc>(context);

    return IconButton(icon: Icon(Icons.swap_vert), onPressed: () {
      bloc.add(LibraryOpened((bloc.state as LibraryLoaded).category, (bloc.state as LibraryLoaded).subCategory, (bloc.state as LibraryLoaded).orderBy, !(bloc.state as LibraryLoaded).ascending));
    });
  }

  @override
  void onDismissed(BuildContext context, DismissDirection dismissDirection, Product product, int index) {
    LibraryBloc bloc = BlocProvider.of<LibraryBloc>(context);
    bloc.add(LibraryProductDeleted(product));
  }


}