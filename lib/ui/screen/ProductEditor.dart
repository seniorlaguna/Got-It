import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/ProductBloc.dart';
import 'package:got_it/data/Categories.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Category.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/widget/ImageLoader.dart';
import 'package:image_picker/image_picker.dart';

import '../../AnalyticsWidget.dart';

class ProductEditor extends StatefulWidget {

  final Product _product;

  static Future<T> start<T>(BuildContext context, Product product) async {
    return Navigator.push<T>(context, MaterialPageRoute(
        builder: (BuildContext context) => ProductEditor(product)
    ));
  }

  const ProductEditor(this._product, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProductEditorState();
  }

}

class ProductEditorState extends State<ProductEditor> {

  String _barcode;
  Category _category;
  SubCategory _subCategory;
  String _imagePath;

  bool _fetching = false;

  GlobalKey _formKey = GlobalKey<FormState>();
  TextEditingController _titleController;
  TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: createState,
      child: BlocListener<ProductBloc, ProductState>(
        listener: onStateChanged,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Builder(
              builder: (BuildContext context) => Scaffold(
                body: CustomScrollView(
                  slivers: [
                    _getAppBar(context),
                    _getAppBody(context)
                  ],
                ),
                floatingActionButton: _getFloatingActionButton(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ProductBloc createState(BuildContext context) {
    return ProductBloc(RepositoryProvider.of<Repository>(context), ProductMode.Editing, Analytics.getInstance().firebaseAnalytics)
      ..add(ProductOpened(widget._product));
  }

  void onStateChanged(BuildContext context, ProductState state) {

    // overwrite local product
    if (state is ProductLoaded) {
      setState(() {

        _titleController.text = state.product.title;
        _barcode = state.product.barcode;
        _category = state.product.category;
        _subCategory = state.product.subCategory;
        _imagePath = state.product.imagePath;
        _notesController.text = state.product.notes;

        _fetching = false;

      });
    }

    else if (state is ProductFetching) {
      setState(() {
        _fetching = true;
      });
    }

  }

  Widget _getAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height / 3,
      backgroundColor: Colors.transparent,
      flexibleSpace: Stack(
        children: [
          ImageLoader(_imagePath),

          Align(
            alignment: Alignment.bottomCenter,
            child: FlatButton(
              color: Colors.pinkAccent,
              child: Text(
                FlutterI18n.translate(context, _barcode == null || _barcode.isEmpty ? "product_editor.scan_barcode" : "product_editor.scan_barcode_again"),
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              onPressed: () => scanBarcodeClicked(context),
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () => takePictureClicked(context),
            ),
          )
        ],
      ),
    );
  }

  Widget _getAppBody(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _titleController,
                onChanged: (val) => onChanged(context, title: val),
                decoration: InputDecoration(
                    labelText: FlutterI18n.translate(context, "product_editor.title"),
                    border: OutlineInputBorder()
                ),
                validator: validateTitle,
                enabled: !_fetching
            ),
          ),

          FormField<Category>(
            initialValue: _category,
            enabled: !_fetching,
            validator: validateCategory,
            builder: (FormFieldState categoryState) {

              return FormField<SubCategory>(
                initialValue: _subCategory,
                enabled: !_fetching,
                validator: validateSubCategory,
                builder: (FormFieldState subCategoryState) {

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      ToggleButtons(


                        children: Categories.map((Category category) => Icon(category.iconData)).toList(),

                        isSelected: Categories.map((Category category) => category == _category).toList(),

                        onPressed: (int i) {
                          BlocProvider.of<ProductBloc>(context).add(ProductChanged(category: Categories[i], subCategory: null));
                          categoryState.didChange(Categories[i]);
                          subCategoryState.didChange(null);
                          setState(() {
                            _category = Categories[i];
                            _subCategory = null;
                          });
                        },

                        borderColor: categoryState.hasError ? Colors.red : Colors.black26,

                      ),

                      AnimatedCrossFade(
                          duration: Duration(milliseconds: 500),
                          crossFadeState: _category == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          firstChild: Container(),
                          secondChild: _category == null ? Container() : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<SubCategory>(

                                value: _subCategory,
                                hint: Text("Unterkategorie",
                                  style: TextStyle(
                                    color: subCategoryState.hasError ? Colors.red : Colors.black
                                  ),
                                ),
                                isExpanded: true,

                                items: _category.subCategories.map((SubCategory subCategory) => DropdownMenuItem<SubCategory>(
                                  value: subCategory,
                                  child: Text(subCategory.title),
                                )).toList(),

                                onChanged: (SubCategory subCategory) {
                                  BlocProvider.of<ProductBloc>(context).add(ProductChanged(subCategory: subCategory));
                                  subCategoryState.didChange(subCategory);
                                  setState(() {
                                    _subCategory = subCategory;
                                  });
                                }
                            ),
                          )
                      )

                    ],
                  );

                },
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _notesController,
                onChanged: (val) => onChanged(context, notes: val),
                decoration: InputDecoration(
                    labelText: FlutterI18n.translate(context, "product_editor.notes"),
                    border: OutlineInputBorder()
                ),
                minLines: 3,
                maxLines: null
            ),
          )
        ],
      ),
    );
  }

  Widget _getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.done),
      onPressed: () {

        if ((_formKey.currentState as FormState).validate()) {
          BlocProvider.of<ProductBloc>(context).add(ProductSaved());
          Navigator.pop(context);
        }

      },
    );
  }

  String validateTitle(String title) {
    if (title == null || title.isEmpty) return "Bitte ausfüllen";
    return null;
  }

  String validateCategory(Category category) {
    return _category == null ? "" : null;
  }

  String validateSubCategory(SubCategory subCategory) {
    return _subCategory == null ? "" : null;
  }

  void takePictureClicked(BuildContext context) async {
    try {
      File pic = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 20);

      if (await pic.exists()) {
        BlocProvider.of<ProductBloc>(context).add(ProductChanged(imagePath: pic.path));
      }

    } catch (e) {
      print(e);
    }

  }

  void scanBarcodeClicked(BuildContext context) async {

    try {
      String barcode = await BarcodeScanner.scan();

      if (barcode != null && barcode.isNotEmpty) {
        BlocProvider.of<ProductBloc>(context).add(ProductChanged(barcode: barcode));
      }

    } catch (e) {
      print(e);
    }

  }

  void onChanged(BuildContext context, {String title, String barcode, String imagePath, Category category, SubCategory subCategory, String notes}) {
    ProductBloc bloc = BlocProvider.of<ProductBloc>(context);
    bloc.add(ProductChanged(
        title: title,
        barcode: barcode,
        imagePath: imagePath,
        category: category,
        subCategory: subCategory,
        notes: notes
    ));
  }
}