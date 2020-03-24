import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/AnalyticsWidget.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/widget/ImageLoader.dart';
import 'package:got_it/ui/widget/ProductCard.dart';

import 'ProductViewer.dart';

abstract class LibraryScreen extends StatelessWidget {

  String get appBarTitle => "";
  Widget get errorBody => Center(child: Text("Error"));
  Widget get loadingBody => Center(child: CircularProgressIndicator());

  LibraryView get libraryView;
  LibraryEvent get initialEvent;

  DismissDirection get allowedDismissDirection;
  Widget get dismissibleBackground;
  Widget get dismissibleSecondBackground;

  void onProductClicked(BuildContext context, Product product, int index) async  {
    await ProductViewer.start(context, product);
    BlocProvider.of<LibraryBloc>(context).add(LibraryRefreshed());
  }

  Widget getAppBarContent(BuildContext context) {
    return ImageLoader(null);
  }

  LibraryBloc createBloc(BuildContext context) {
    return LibraryBloc(libraryView, RepositoryProvider.of<Repository>(context), Analytics.getInstance().firebaseAnalytics)
      ..add(initialEvent);
  }

  Widget getAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text(FlutterI18n.translate(context, appBarTitle)),
      expandedHeight: MediaQuery.of(context).size.height / 3,
      flexibleSpace: getAppBarContent(context),
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
      child: loadingBody,
    );
  }

  Widget getAppBodyLoaded(BuildContext context, List<Product> products) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int i) {
          return Dismissible(
            key: ValueKey(products[i].id),
            direction: allowedDismissDirection,
            onDismissed: (DismissDirection dismissDirection) => onDismissed(context, dismissDirection, products[i], i),
            background: dismissibleBackground,
            secondaryBackground: dismissibleSecondBackground,
            child: ProductCard(products[i], onTap: () => onProductClicked(context, products[i], i)),
          );
        },
          childCount: products.length,
        )
    );
  }

  Widget getAppBodyLoadedEmpty(BuildContext context) {
    return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text("Empty"),)
    );
  }

  Widget getAppBodyError(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: errorBody,
    );
  }

  void onDismissed(BuildContext context, DismissDirection dismissDirection, Product product, int index);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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

