import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/widget/ProductCard.dart';

import 'ProductScreen.dart';

class ProductListScreen extends StatelessWidget {
  static Future<dynamic> start(BuildContext context, String titleRegex,
      Set<String> includedTags, Set<String> excludedTags,
      {appBarTitle = "", libraryView = LibraryView.Tag}) async {
    return Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ProductListScreen(
          titleRegex, includedTags, excludedTags, appBarTitle, libraryView);
    }));
  }

  final String titleRegex;
  final Set<String> includedTags;
  final Set<String> excludedTags;

  final String appBarTitle;

  final LibraryView libraryView;

  final DismissDirection allowedDismissDirection = DismissDirection.endToStart;
  final Widget dismissibleBackgroundDelete = Container(
    color: Colors.black12,
    child: Align(
        alignment: Alignment(0.8, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("delete", style: TextStyle(fontSize: 20, color: Colors.white)),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.delete, color: Colors.white),
            )
          ],
        )),
  );

  final Widget dismissibleBackgroundRestore = Container(
    color: Color(0xffdc9a9b),
    child: Align(
        alignment: Alignment(0.8, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("recover",
                style: TextStyle(fontSize: 20, color: Colors.white)),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.undo, color: Colors.white),
            )
          ],
        )),
  );

  ProductListScreen(this.titleRegex, this.includedTags, this.excludedTags,
      this.appBarTitle, this.libraryView);

  Widget getAppBarContent(BuildContext context) {
    String fallbackAsset;
    switch (libraryView) {
      case LibraryView.Tag:
        fallbackAsset = "assets/tags/${includedTags.first}.jpg";
        break;
      case LibraryView.Trash:
        fallbackAsset = "assets/trash_circle.jpg";
        break;
      case LibraryView.Favorite:
        fallbackAsset = "assets/favorite_circle.jpg";
        break;
      case LibraryView.Search:
        fallbackAsset = "assets/search_circle.jpg";
        break;
    }

    final double width = MediaQuery.of(context).size.width / 2.4;

    final String heroTag =
        (libraryView == LibraryView.Search) ? "search" : includedTags.first;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
              child: Hero(
                  tag: heroTag,
                  child: ClipOval(
                    child: Image.asset(fallbackAsset,
                        width: width, fit: BoxFit.cover),
                  ))),
          Text(FlutterI18n.translate(context, appBarTitle),
              style:
                  TextStyle(fontSize: 28, color: Theme.of(context).accentColor))
        ]);
  }

  LibraryBloc createBloc(BuildContext context) {
    return LibraryBloc(libraryView, RepositoryProvider.of<Repository>(context))
      ..add(LibrarySearched(titleRegex, includedTags, excludedTags));
  }

  Widget getAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height / 2.5,
      flexibleSpace: getAppBarContent(context),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.black),
    );
  }

  Widget getAppBody(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (BuildContext context, LibraryState state) {
        if (state is LibraryLoading) {
          return getAppBodyLoading(context);
        } else if (state is LibraryLoaded) {
          return state.products.isEmpty
              ? getAppBodyLoadedEmpty(context)
              : getAppBodyLoaded(context, state.products);
        } else {
          return getAppBodyError(context);
        }
      },
    );
  }

  Widget getAppBodyLoading(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget getAppBodyLoaded(BuildContext context, List<Product> products) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int i) {
        return Dismissible(
            key: ValueKey(products[i].id),
            direction: allowedDismissDirection,
            onDismissed: (DismissDirection dismissDirection) =>
                onDismissed(context, dismissDirection, products[i], i),
            background: (libraryView == LibraryView.Trash)
                ? dismissibleBackgroundRestore
                : dismissibleBackgroundDelete,
            child: ProductCard(products[i], () async {
              await ProductScreen.start(context, products[i], false, false);
              BlocProvider.of<LibraryBloc>(context).add(LibraryRefreshed());
            }, libraryView));
      },
      childCount: products.length,
    ));
  }

  Widget getImageWithText(BuildContext context, String message) {
    return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(FlutterI18n.translate(context, message),
                style: TextStyle(fontSize: 24, color: Colors.grey)),
          ),
        ));
  }

  Widget getAppBodyLoadedEmpty(BuildContext context) {
    String text;
    switch (libraryView) {
      case LibraryView.Trash:
        text = "product_list.empty_trash";
        break;
      case LibraryView.Search:
        text = "product_list.nothing_found";
        break;
      default:
        text = "product_list.empty";
    }

    return getImageWithText(context, text);
  }

  Widget getAppBodyError(BuildContext context) {
    return getImageWithText(context, "product_list.error");
  }

  void onDismissed(BuildContext context, DismissDirection dismissDirection,
      Product product, int index) {
    if (libraryView == LibraryView.Trash) {
      BlocProvider.of<LibraryBloc>(context)
          .add(LibraryProductRecovered(product, index));
    } else {
      BlocProvider.of<LibraryBloc>(context).add(LibraryProductDeleted(product));
    }
  }

  void _onAddNewProduct(BuildContext context) async {
    // add a new product and if you are
    // in a specific tag use it for the new product
    Product newProduct = Product.empty();
    if (libraryView == LibraryView.Tag) {
      newProduct.tags.add(includedTags.first);
    }

    await ProductScreen.start(context, newProduct, true, true);
    BlocProvider.of<LibraryBloc>(context).add(LibraryRefreshed());
  }

  void _clearTrash(BuildContext context) async {
    await RepositoryProvider.of<Repository>(context).clearTrash();
    BlocProvider.of<LibraryBloc>(context).add(LibraryRefreshed());
    Navigator.of(context).pop();
  }

  void _onClearTrash(BuildContext context) {
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text("clear trash?"),
          content: Text("this will remove all products from your trash"),
          actions: [
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel",
                    style: TextStyle(color: Theme.of(context).accentColor))),
            FlatButton(
                onPressed: () => _clearTrash(context),
                child: Text("OK",
                    style: TextStyle(color: Theme.of(context).accentColor)))
          ],
        ));
  }

  Widget getFAB(BuildContext context) {
    // in trash you can delete everything
    // else you can add a new product
    IconData iconData =
        (libraryView == LibraryView.Trash) ? Icons.delete : Icons.add;

    // set the right callback function
    Function callback = (libraryView == LibraryView.Trash)
        ? () => _onClearTrash(context)
        : () => _onAddNewProduct(context);

    return FloatingActionButton(
      onPressed: callback,
      child: Icon(iconData, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryBloc>(
      create: createBloc,
      child: SafeArea(
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            floatingActionButton: getFAB(context),
            body: CustomScrollView(
              slivers: <Widget>[getAppBar(context), getAppBody(context)],
            ),
          );
        }),
      ),
    );
  }
}
