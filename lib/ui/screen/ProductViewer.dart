import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:got_it/AnalyticsWidget.dart';
import 'package:got_it/bloc/ProductBloc.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductEditor.dart';
import 'package:got_it/ui/widget/ImageLoader.dart';
import 'package:got_it/ui/widget/MyIconButton.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ProductEditor.dart';

class ProductViewer extends StatefulWidget {

  final Product _product;

  const ProductViewer(this._product, {Key key}) : super(key: key);

  static Future<T> start<T>(BuildContext context, Product product) async {
    return Navigator.push<T>(context, MaterialPageRoute(
        builder: (BuildContext context) => ProductViewer(product)
    ));
  }

  @override
  _ProductViewerState createState() => _ProductViewerState();
}

class _ProductViewerState extends State<ProductViewer> {

  bool infoExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ProductBloc(RepositoryProvider.of<Repository>(context), ProductMode.Viewing, Analytics.getInstance().firebaseAnalytics)..add(ProductOpened(widget._product)),
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                _getAppBar(context),
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (BuildContext context, ProductState state) {

                    if (state is ProductLoading) {
                      return _getLoadingBody(context);
                    }
                    else if (state is ProductLoaded) {
                      return _getLoadedBody(context, state.product);
                    }
                    else {
                      return _getErrorBody(context);
                    }

                  },
                )
              ],
            ),
            floatingActionButton: _getFloatingActionButton(context),
          );
        },
      ),
    );
  }

  Widget _getAppBar(BuildContext context) {
    return SliverAppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: BlocBuilder<ProductBloc, ProductState>(
              builder: (BuildContext context, ProductState state) {

                if (state is ProductLoaded) {
                  return ImageLoader(state.product.imagePath);
                }

                return ImageLoader(null);
              }
          ),
          expandedHeight: MediaQuery.of(context).size.height / 3,
        );
  }

  Widget _getLoadingBody(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _getLoadedBody(BuildContext context, Product product) {

    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          _getProductDescription(context, product),
          _getProductActions(context, product)
        ],
      ),
    );
  }

  Widget _getErrorBody(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text("Fehler"),
      ),
    );
  }

  Widget _getProductDescription(BuildContext context, Product product) {

    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            GestureDetector(
              onTap: () => setState(() {
                infoExpanded = !infoExpanded;
              }),
              child: Stack(
                  alignment: Alignment(0,0),
                  children: [
                    Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(product.title, style: TextStyle(fontSize: 24)),
                        )
                    ),

                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        alignment: Alignment(1, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(infoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                        ),
                      ),
                    )
                  ]
              ),
            ),

            AnimatedCrossFade(
              firstChild: Container(
              ),
              crossFadeState: infoExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 500),
              secondChild: Container(
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(product.notes, style: TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );

  }

  Widget _getProductActions(BuildContext context, Product product) {
    return _getProductStandardActions(context, product);
  }

  Widget _getProductStandardActions(BuildContext context, Product product) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                MyIconButton(() => _onFavoriteClicked(context, product), product.favorite ? Icons.favorite : Icons.favorite_border, "Like"),
                MyIconButton(() => _onHowToClicked(context, product), Icons.live_tv, "How To"),
                MyIconButton(() => _onShareClicked(context, product), Icons.share, "Share"),
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  MyIconButton(() => _onBuyClicked(context, product), Icons.shopping_cart, "Buy"),
                  MyIconButton(() => _onInfoClicked(context, product), Icons.info_outline, "Info"),
                ]
            )
          ],
        ),
      ),
    );
  }

  Widget _getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () async {
          var bloc = BlocProvider.of<ProductBloc>(context);
          await ProductEditor.start(context, (bloc.state as ProductLoaded).product);
          bloc.add(ProductRefreshed());
        }
    );
  }

  void _onInfoClicked(BuildContext context, Product product) async {

    String url = "https://lagunabrothers.de/gotit/api/info?barcode=${product.barcode}&title=${product.title}";
    if (await canLaunch(url)) {
      launch(url);
    }
  }

  void _onHowToClicked(BuildContext context, Product product) async {

    String url = "https://lagunabrothers.de/gotit/api/howto?barcode=${product.barcode}&title=${product.title}";
    if (await canLaunch(url)) {
      launch(url);
    }

  }

  void _onFavoriteClicked(BuildContext context, Product product) async {
    ProductBloc bloc = BlocProvider.of<ProductBloc>(context);
    bloc.add(ProductLiked(product));
  }

  void _onBuyClicked(BuildContext context, Product product) async {

    String url = "https://lagunabrothers.de/gotit/api/buy?barcode=${product.barcode}&title=${product.title}";
    if (await canLaunch(url)) {
      launch(url);
    }

  }

  void _onShareClicked(BuildContext context, Product product) async {
    Share.share("Check out this Product: ${product.title}");
  }
}