import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Category.dart';
import 'package:got_it/model/Product.dart';

abstract class ProductEvent extends Equatable {}
class ProductRefreshed extends ProductEvent {
  @override
  List<Object> get props => [];
}
class ProductChanged extends ProductEvent {
  final String title;
  final String barcode;
  final String imagePath;
  final Category category;
  final SubCategory subCategory;
  final String notes;

  ProductChanged({this.title, this.barcode, this.imagePath, this.category, this.subCategory, this.notes});

  @override
  List<Object> get props => [];
}
class ProductSaved extends ProductEvent {
  @override
  List<Object> get props => [];
}

abstract class ProductAction extends ProductEvent {
  final Product _product;

  ProductAction(this._product);

  @override
  List<Object> get props => [_product];
}
class ProductOpened extends ProductAction {
  ProductOpened(Product product) : super(product);
}
class ProductLiked extends ProductAction {
  ProductLiked(Product product) : super(product);
}
class ProductDisliked extends ProductAction {
  ProductDisliked(Product product) : super(product);
}


abstract class ProductState extends Equatable {}
class ProductLoading extends ProductState {
  @override
  List<Object> get props => [];
}
class ProductLoaded extends ProductState {
  final Product product;

  ProductLoaded(this.product);

  @override
  List<Object> get props => [product];
}
class ProductFetching extends ProductState {
  @override
  List<Object> get props => [];
}
class ProductError extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {

  final Repository _repository;
  final ProductMode _productMode;
  Product _product;
  final FirebaseAnalytics _firebaseAnalytics;

  ProductBloc(this._repository, this._productMode, this._firebaseAnalytics);

  @override
  ProductState get initialState => ProductLoading();

  @override
  Stream<ProductState> mapEventToState(ProductEvent event) async* {
    try {
      if (event is ProductOpened) {
        _firebaseAnalytics.logEvent(name: "select_content", parameters: {
          "content_type" : "$_productMode",
          "item_id" : event._product.barcode ?? event._product.title
        });

        _product = event._product;
        yield ProductLoaded(event._product);

      }

      else if (event is ProductLiked) {
        assert(_productMode == ProductMode.Viewing);
        assert(state is ProductLoaded);

        _firebaseAnalytics.logEvent(name: "like_content", parameters: {
          "content_type" : "$_productMode",
          "item_id" : event._product.barcode ?? event._product.title
        });

        _repository.like(event._product, true);
        ProductLoaded((state as ProductLoaded).product.copyWith(favorite: true));
      }

      else if (event is ProductDisliked) {
        assert(_productMode == ProductMode.Viewing);
        assert(state is ProductLoaded);

        _firebaseAnalytics.logEvent(name: "dislike_content", parameters: {
          "content_type" : "$_productMode",
          "item_id" : event._product.barcode ?? event._product.title
        });

        _repository.like(event._product, false);
        ProductLoaded((state as ProductLoaded).product.copyWith(favorite: false));

      }

      else if (event is ProductChanged) {
        assert(_productMode == ProductMode.Editing);
        assert(state is ProductLoaded);

        // save changes
        _product = _product.copyWith(
            title: event.title,
          barcode: event.barcode,
          imagePath: event.imagePath,
          category: event.category,
          subCategory: event.subCategory,
          notes: event.notes,
        );

        if (event.barcode != null) {
          _firebaseAnalytics.logEvent(name: "scan_barcode_editor");

          yield ProductFetching();

          // TODO("Network request to retrieve information")

          yield ProductLoaded(_product);
        }
        else if (event.imagePath != null) {
          _firebaseAnalytics.logEvent(name: "take_image");

          yield ProductLoaded(_product);
        }

      }

      else if (event is ProductSaved) {
        assert(_productMode == ProductMode.Editing);
        assert(state is ProductLoaded);

        _firebaseAnalytics.logEvent(name: "save_content", parameters: {
          "content_type" : "$_productMode",
          "item_id" : _product.barcode ?? _product.title
        });

        _product.id == 0 ? _repository.insert(_product) : _repository.update(_product);
      }

      else if (event is ProductRefreshed) {
        assert(_productMode == ProductMode.Editing || _productMode == ProductMode.Viewing);
        assert(state is ProductLoaded);

        _firebaseAnalytics.logEvent(name: "refresh_content", parameters: {
          "content_type" : "$_productMode",
        });

        if (_productMode == ProductMode.Editing) {
          yield ProductLoaded(_product);
        } else if (_productMode == ProductMode.Viewing) {
          Product p = await _repository.getProductById(_product.id);
          yield ProductLoaded(p == null ? _product : p);
        }
      }

      else {
        throw Exception("Unknown event ${event.runtimeType} in ProductBloc!");
      }
    }
    catch (e) {
      _firebaseAnalytics.logEvent(name: "error_product_bloc", parameters: {
        "message": "$e",
      });

      print(e);
      yield ProductError();
    }

  }

}

enum ProductMode {
  Editing,
  Viewing
}