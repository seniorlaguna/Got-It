import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/ProductBloc.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/MainScreen.dart';
import 'package:got_it/ui/widget/EmbeddedBarcodeScanner.dart';
import 'package:got_it/ui/widget/ImagePickerDialog.dart';
import 'package:got_it/ui/widget/ZoomAnimation.dart';
import 'package:got_it/ui/widget/ImageIconButton.dart';
import 'package:got_it/ui/widget/TagChooser.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductScreen extends StatefulWidget {
  final Product _product;
  final bool _edit;
  final bool _closeOnBack;

  static final TextStyle _titleTextStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w500);

  static final TextStyle _tagTextStyle = TextStyle(
      fontSize: 16, color: Color(0xffdc9a9b), fontWeight: FontWeight.w700);

  static Future<dynamic> start(
      BuildContext context, Product product, bool edit, bool closeOnBack) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductScreen(product, edit, closeOnBack)));
  }

  const ProductScreen(this._product, this._edit, this._closeOnBack, {Key key})
      : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: "formKey");
  final GlobalKey<TagSelectorState> _tagSelectorKey =
      GlobalKey(debugLabel: "tagSelectorKey");

  // like animation
  AnimationController _responseAnimationController;
  IconData _iconDataForResponse;

  @override
  void initState() {
    super.initState();
    _responseAnimationController =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _responseAnimationController.dispose();
    super.dispose();
  }

  ProductBloc createBloc(BuildContext context) {
    return ProductBloc(RepositoryProvider.of<Repository>(context))
      ..add(ProductOpenedEvent(widget._product, widget._edit));
  }

  void onEditClicked(BuildContext context) {
    ProductBloc bloc = BlocProvider.of<ProductBloc>(context);
    Product product = bloc.state.product;
    bloc.add(ProductOpenedEvent(product, true));
  }

  void onBackClicked(BuildContext context) {
    ProductBloc bloc = BlocProvider.of<ProductBloc>(context);

    if (bloc.state is ProductLoadingState ||
        bloc.state is ProductErrorState ||
        bloc.state is ProductViewingState ||
        (bloc.state is ProductEditingState && widget._closeOnBack)) {
      Navigator.pop(context);
      return;
    }

    assert(bloc.state is ProductEditingState);

    Product product = bloc.state.product;
    bloc.add(ProductOpenedEvent(product, false));
  }

  Widget getAppBar(BuildContext context, ProductState state) {
    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => onBackClicked(context)),
      title: Text(state.product.title ??
          FlutterI18n.translate(context, "product.title.new")),
      centerTitle: true,
      actions: (state is ProductViewingState)
          ? [
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => onEditClicked(context))
            ]
          : [],
    );
  }

  void onImageTapped(BuildContext context) {
    ProductState state = BlocProvider.of<ProductBloc>(context).state;
    assert(state is ProductEditingState || state is ProductViewingState);

    if (state is ProductEditingState) {
      onTakePicture(context);
    }
  }

  void onImageDoubleTapped(BuildContext context) {
    ProductState state = BlocProvider.of<ProductBloc>(context).state;
    assert(state is ProductEditingState || state is ProductViewingState);

    if (state is ProductViewingState) {
      onToggleLike(context);
    }
  }

  Widget getProductImage(BuildContext context, Product product) {
    // product image size
    double width = MediaQuery.of(context).size.width;
    double height = width;

    return Flexible(
        child: GestureDetector(
      onTap: () => onImageTapped(context),
      onDoubleTap: () => onImageDoubleTapped(context),
      child: Stack(
        children: [
          Hero(
            tag: product.id ?? -1,
            child: FadeInImage(
              placeholder: Image.asset("assets/transparent_image.png").image,
              image: (product.imagePath == null ||
                      !File(product.imagePath).existsSync())
                  ? Image.asset("assets/default_product_image.png").image
                  : Image.file(File(product.imagePath)).image,
              width: width,
              height: height,
              fit: BoxFit.fill,
            ),
          ),
          BlocListener<ProductBloc, ProductState>(
            condition: (previous, now) {
              if (!previous.product.like && now.product.like) {
                setState(() {
                  _iconDataForResponse = Icons.favorite;
                });
                return true;
              }

              if (previous.product.barcode != now.product.barcode) {
                setState(() {
                  _iconDataForResponse = Icons.done;
                });
                return true;
              }

              return false;
            },
            listener: (_, __) {
              if (!_responseAnimationController.isAnimating) {
                _responseAnimationController..forward(from: 0);
              }
            },
            child: SizedBox(
                height: height,
                width: width,
                child: Center(
                    child: ZoomAnimation(
                        _responseAnimationController,
                        Icon(_iconDataForResponse,
                            size: 48, color: Colors.white)))),
          ),
        ],
      ),
    ));
  }

  Widget getErrorBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/empty.png",
            width: MediaQuery.of(context).size.width / 2,
            fit: BoxFit.fitWidth,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(FlutterI18n.translate(context, "product_list.error"),
                style: TextStyle(fontSize: 24, fontFamily: "IndieFlower")),
          )
        ],
      ),
    );
  }

  Widget getLoadingBody(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }

  Widget getEditingIconBar(BuildContext context) {
    Product p = BlocProvider.of<ProductBloc>(context).state.product;
    bool barcode_done = (p.barcode != null && p.barcode.isNotEmpty);

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ImageIconButton(
          "assets/icons/${barcode_done ? "barcode_done.png" : "barcode.png"}",
          () => onScanBarcode(context)),
      ImageIconButton("assets/icons/camera.png", () => onTakePicture(context)),
    ]);
  }

  Widget getViewingIconBar(BuildContext context) {
    bool like = BlocProvider.of<ProductBloc>(context).state.product.like;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ImageIconButton(
                like
                    ? "assets/icons/heart_full.png"
                    : "assets/icons/heart_empty.png",
                () => onToggleLike(context)),
            ImageIconButton("assets/icons/share.png", () => onShare(context)),
          ],
        ),
        Row(
          children: [
            // TODO: Hier können wir Unternehmen mit einbinden (Monetarisieren!!!)
            /* ImageIconButton("assets/icons/info.png", () => onShowInfo(context)),
            ImageIconButton(
                "assets/icons/play.png", () => onShowHowTo(context)),
            ImageIconButton(
                "assets/icons/shop.png", () => onBuyProduct(context)), */
          ],
        )
      ],
    );
  }

  Widget getViewingBody(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getProductImage(context, product),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: getViewingIconBar(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              Text(product.title ?? "", style: ProductScreen._titleTextStyle),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Wrap(
            spacing: 8,
            direction: Axis.horizontal,
            children: product.productTags
                .map((tag) => Text("#${FlutterI18n.translate(context, tag)}",
                    style: ProductScreen._tagTextStyle))
                .toList(),
          ),
        )
      ],
    );
  }

  String validateForm(BuildContext context, String value) {
    if (value.isEmpty) {
      return FlutterI18n.translate(
          context, FlutterI18n.translate(context, "product.validator.no_name"));
    }

    if (_tagSelectorKey.currentState.tags.isEmpty) {
      return FlutterI18n.translate(context, "product.validator.no_tag");
    }

    if (!_tagSelectorKey.currentState.tags
        .any((element) => mainTags.contains(element))) {
      return FlutterI18n.translate(context, "product.validator.no_main_tag");
    }

    return null;
  }

  Widget getEditingBody(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getProductImage(context, product),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: getEditingIconBar(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: TextFormField(
              controller: _textEditingController..text = product.title,
              decoration: InputDecoration(
                  hintText:
                      FlutterI18n.translate(context, "product.title.hint"),
                  isDense: true),
              validator: (String value) => validateForm(context, value),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: TagSelector(
            product.productTags,
            key: _tagSelectorKey,
          ),
        )
      ],
    );
  }

  Widget getAppBody(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
        builder: (BuildContext context, ProductState state) {
      if (state is ProductLoadingState)
        return getLoadingBody(context);
      else if (state is ProductViewingState)
        return getViewingBody(context, state.product);
      else if (state is ProductEditingState)
        return getEditingBody(context, state.product);

      return getErrorBody(context);
    });
  }

  void onSubmitClicked(BuildContext context) {
    if (!_formKey.currentState.validate()) return;

    ProductBloc bloc = BlocProvider.of<ProductBloc>(context);

    String title = _textEditingController.text;
    Set<String> tags = _tagSelectorKey.currentState.tags;
    if (bloc.state.product.like) tags.add(favoriteTag);
    if (bloc.state.product.delete) tags.add(deleteTag);

    bloc.add(ProductChangedEvent(
        bloc.state.product.copyWith(title: title, tags: tags), true));
  }

  Widget getFAB(BuildContext context) {
    if (!(BlocProvider.of<ProductBloc>(context).state is ProductEditingState))
      return null;

    return FloatingActionButton(
        child: Icon(Icons.done, color: Colors.white),
        onPressed: () => onSubmitClicked(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
        create: createBloc,
        child: SafeArea(
          child: Builder(builder: (BuildContext context) {
            return BlocBuilder<ProductBloc, ProductState>(
              builder: (BuildContext context, ProductState state) {
                return Scaffold(
                  appBar: getAppBar(context, state),
                  body: getAppBody(context),
                  floatingActionButton: getFAB(context),
                );
              },
            );
          }),
        ));
  }

  void onToggleLike(BuildContext context) {
    ProductBloc bloc = BlocProvider.of<ProductBloc>(context);

    Set<String> tags = Set<String>.from(bloc.state.product.tags);
    if (tags.contains(favoriteTag)) {
      tags.remove(favoriteTag);
    } else {
      tags.add(favoriteTag);
    }

    bloc.add(
        ProductChangedEvent(bloc.state.product.copyWith(tags: tags), false));
  }

  void onShare(BuildContext context) {
    ProductState state = BlocProvider.of<ProductBloc>(context).state;
    assert(state is ProductViewingState);

    if (state.product.imagePath == null || state.product.imagePath.isEmpty) {
      Share.share(FlutterI18n.translate(context, "product.share.text"),
          subject: FlutterI18n.translate(context, "product.share.subject"));
    } else {
      Share.shareFiles([state.product.imagePath],
          subject: FlutterI18n.translate(context, "product.share.subject"),
          text: FlutterI18n.translate(context, "product.share.text"));
    }
  }

  void onShowInfo(BuildContext context) {
    ProductState state = BlocProvider.of<ProductBloc>(context).state;
    assert(state is ProductViewingState);

    // no barcode
    if (state.product.barcode == null || state.product.barcode.isEmpty) {
      print("No Barcode found");
    }

    // TODO: add info domain
    launch("https://www.google.de");
  }

  void onShowHowTo(BuildContext context) {
    ProductState state = BlocProvider.of<ProductBloc>(context).state;
    assert(state is ProductViewingState);

    // no barcode
    if (state.product.barcode == null || state.product.barcode.isEmpty) {
      print("No Barcode found");
    }

    // TODO: add how to domain
    launch("https://youtube.de");
  }

  void onBuyProduct(BuildContext context) {
    ProductState state = BlocProvider.of<ProductBloc>(context).state;
    assert(state is ProductViewingState);

    // no barcode
    if (state.product.barcode == null || state.product.barcode.isEmpty) {
      print("No Barcode found");
    }

    // TODO: add buy domain
    launch("https://amazon.de");
  }

  Future<void> onTakePicture(BuildContext context) async {
    CameraDescription camera = (await availableCameras()).first;

    // file paths
    String tmpDirPath = (await getTemporaryDirectory()).path;
    String targetPath = join((await getApplicationDocumentsDirectory()).path,
        "${DateTime.now()}.jpg");

    // camera size
    double width = MediaQuery.of(context).size.width;
    double height = width;
    double appBarHeight = AppBar().preferredSize.height;

    // get bloc
    ProductBloc bloc = BlocProvider.of<ProductBloc>(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ImagePickerDialog(
              camera, tmpDirPath, targetPath, width, height, appBarHeight, () {
            // called if image is saved
            bloc.add(ProductChangedEvent(
                bloc.state.product.copyWith(imagePath: targetPath), false));
          });
        });
  }

  void onBarcodeScanned(BuildContext context, String barcode) async {
    // get bloc and repository
    ProductBloc bloc = BlocProvider.of<ProductBloc>(context);
    Repository repository = RepositoryProvider.of(context);

    if ((await repository.getProductByBarcode(barcode)) != null) {
      // already in collection
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Sorry"),
            content: Text("this product is already in your collection"),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("ok"))
            ],
          ));
      return;
    }

    bloc.add(ProductChangedEvent(
        bloc.state.product.copyWith(barcode: barcode), false));
  }

  Future<dynamic> onScanBarcode(BuildContext context) {
    // camera size
    double width = MediaQuery.of(context).size.width;
    double height = width;
    double appBarHeight = AppBar().preferredSize.height;

    return showDialog(
        context: context,
        child: EmbeddedBarcodeScannerDialog(width, height, appBarHeight,
            (barcode) => onBarcodeScanned(context, barcode)));
  }
}
