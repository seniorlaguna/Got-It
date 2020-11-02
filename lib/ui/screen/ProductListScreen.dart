import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/widget/ImageLoader.dart';
import 'package:got_it/ui/widget/ProductCard.dart';

import 'ProductScreen.dart';

class ProductListScreen extends StatelessWidget {

  static Future<dynamic> start(BuildContext context, String titleRegex, Set<String> includedTags, Set<String> excludedTags, {appBarTitle = "", libraryView = LibraryView.Tag}) async {
    return Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ProductListScreen(titleRegex, includedTags, excludedTags, appBarTitle, libraryView);
    }));
  }

  final String titleRegex;
  final Set<String> includedTags;
  final Set<String> excludedTags;

  final String appBarTitle;

  final LibraryView libraryView;

  final DismissDirection allowedDismissDirection = DismissDirection.endToStart;
  final Widget dismissibleBackgroundDelete = Container(
    color: Colors.red,
    child: Center(
      child: Icon(Icons.delete, color: Colors.white),
    ),
  );

  final Widget dismissibleBackgroundRestore = Container(
    color: Colors.lightGreen,
    child: Center(
      child: Icon(Icons.restore_from_trash_outlined, color: Colors.white),
    ),
  );

  ProductListScreen(this.titleRegex, this.includedTags, this.excludedTags, this.appBarTitle, this.libraryView);

  Widget getAppBarContent(BuildContext context) {
    final String fallbackAsset = (libraryView == LibraryView.Search) ? "assets/search.jpg" : "assets/tags/${includedTags.first}.jpg";
    final String heroTag = (libraryView == LibraryView.Search) ? "search" : includedTags.first;

    return ImageLoader(null, fallbackAsset: fallbackAsset, heroTag: heroTag);
  }

  LibraryBloc createBloc(BuildContext context) {
    return LibraryBloc(libraryView, RepositoryProvider.of<Repository>(context))
      ..add(LibrarySearched(titleRegex, includedTags, excludedTags));
  }

  Widget getAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text(FlutterI18n.translate(context, appBarTitle), style: TextStyle(color: Colors.white, fontSize: 20)),
      expandedHeight: MediaQuery.of(context).size.height / 3,
      flexibleSpace: getAppBarContent(context),
      iconTheme: IconThemeData(
        color: Colors.white
      ),
    );
  }

  Widget getAppBody(BuildContext context) {

    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (BuildContext context, LibraryState state) {

        if (state is LibraryLoading) {
          return getAppBodyLoading(context);
        }
        else if (state is LibraryLoaded) {
          return state.products.isEmpty ? getAppBodyLoadedEmpty(context) : getAppBodyLoaded(context, state.products);
        }
        else {
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
        delegate: SliverChildBuilderDelegate((BuildContext context, int i) {
          return Dismissible(
            key: ValueKey(products[i].id),
            direction: allowedDismissDirection,
            onDismissed: (DismissDirection dismissDirection) => onDismissed(context, dismissDirection, products[i], i),
            background: (libraryView == LibraryView.Trash) ? dismissibleBackgroundRestore : dismissibleBackgroundDelete,
            child: ProductCard(products[i], () async {
              await ProductScreen.start(context, products[i], false, false);
              BlocProvider.of<LibraryBloc>(context).add(LibraryRefreshed());
            })
          );
        },
          childCount: products.length,
        )
    );
  }

  Widget getImageWithText(BuildContext context, String message) {
    return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/empty.png", width: MediaQuery.of(context).size.width/2, fit: BoxFit.fitWidth,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(FlutterI18n.translate(context, message), style: TextStyle(fontSize: 24, fontFamily: "IndieFlower")),
            )
          ],
        ),)
    );
  }

  Widget getAppBodyLoadedEmpty(BuildContext context) {
    return getImageWithText(context, libraryView == LibraryView.Search ? "product_list.nothing_found" : "product_list.empty");
  }

  Widget getAppBodyError(BuildContext context) {
    return getImageWithText(context, "product_list.error");
  }

  void onDismissed(BuildContext context, DismissDirection dismissDirection, Product product, int index) {
    if (libraryView == LibraryView.Trash) {
      BlocProvider.of<LibraryBloc>(context).add(LibraryProductRecovered(product, index));
    }
    else {
      BlocProvider.of<LibraryBloc>(context).add(LibraryProductDeleted(product));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryBloc>(
      create: createBloc,
      child: SafeArea(
        child: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: CustomScrollView(
                  slivers: <Widget>[
                    getAppBar(context),
                    getAppBody(context)
                  ],
                ),
              );
            }
        ),
      ),
    );
  }

}
