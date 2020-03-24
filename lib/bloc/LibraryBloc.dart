import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Category.dart';
import 'package:got_it/model/Product.dart';

/// Library Events
abstract class LibraryEvent extends Equatable {}
class LibraryOpened extends LibraryEvent {
  final Category _category;
  final SubCategory _subCategory;
  final String _orderBy;
  final bool _ascending;

  LibraryOpened(this._category, this._subCategory, this._orderBy, this._ascending);

  @override
  List<Object> get props => [_category, _subCategory, _orderBy, _ascending];
}


abstract class LibraryProductAction extends LibraryEvent {
  final Product _product;

  LibraryProductAction(this._product);

  @override
  List<Object> get props => [_product];
}
class LibraryProductDeleted extends LibraryProductAction {
  LibraryProductDeleted(Product product) : super(product);
}
class LibraryProductRecovered extends LibraryProductAction {
  final int index;
  LibraryProductRecovered(Product product, this.index) : super(product);
}
class LibraryProductLiked extends LibraryProductAction {
  LibraryProductLiked(Product product) : super(product);
}
class LibraryProductDisliked extends LibraryProductAction {
  LibraryProductDisliked(Product product) : super(product);
}
class LibraryProductAddedToLibrary extends LibraryProductAction {
  LibraryProductAddedToLibrary(Product product) : super(product);
}

class LibraryRefreshed extends LibraryEvent {
  @override
  List<Object> get props => [];
}

/// Library States
abstract class LibraryState extends Equatable {}
class LibraryLoading extends LibraryState {
  @override
  List<Object> get props => [];
}
class LibraryLoaded extends LibraryState {
  final List<Product> products;
  final Category category;
  final SubCategory subCategory;
  final String orderBy;
  final bool ascending;

  LibraryLoaded(this.products, this.category, this.subCategory, this.orderBy, this.ascending);

  LibraryLoaded copyWith({List<Product> products, Category category, SubCategory subCategory, String orderBy, bool ascending}) {
    return LibraryLoaded(
      products ?? this.products,
      category ?? this.category,
      subCategory ?? this.subCategory,
      orderBy ?? this.orderBy,
      ascending ?? this.ascending
    );
  }

  @override
  List<Object> get props => [products, category, subCategory, orderBy, ascending];
}
class LibraryError extends LibraryState {
  @override
  List<Object> get props => [];
}

/// Library BLoC
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {

  final LibraryView _libraryView;
  final Repository _repository;
  final FirebaseAnalytics _analytics;

  LibraryBloc(this._libraryView, this._repository, this._analytics);

  @override
  LibraryState get initialState => LibraryLoading();

  @override
  Stream<LibraryState> mapEventToState(LibraryEvent event) async* {

    try {
      
      if (event is LibraryOpened) {
        _analytics.logEvent(name: "select_content", parameters: {
          "content_type" : "$_libraryView",
        });

        yield LibraryLoading();
        yield await _onOpened(event._category, event._subCategory, event._orderBy, event._ascending);
      }
      
      else if (event is LibraryProductDeleted) {
        _analytics.logEvent(name: "delete_content", parameters: {
          "content_type" : "$_libraryView",
          "item_id" : event._product.barcode ?? event._product.title
        });

        yield _onProductDeleted(event._product);
      }
      
      else if (event is LibraryProductRecovered) {
        _analytics.logEvent(name: "recover_content", parameters: {
          "content_type" : "$_libraryView",
          "item_id" : event._product.barcode ?? event._product.title
        });

        yield _onProductRecovered(event._product, event.index);
      }
      
      else if (event is LibraryProductLiked) {
        _analytics.logEvent(name: "like_content", parameters: {
          "content_type" : "$_libraryView",
          "item_id" : event._product.barcode ?? event._product.title
        });

        yield _onProductLiked(event._product);
      }
      
      else if (event is LibraryProductDisliked) {
        _analytics.logEvent(name: "dislike_content", parameters: {
          "content_type" : "$_libraryView",
          "item_id" : event._product.barcode ?? event._product.title
        });

        yield _onProductDisliked(event._product);
      }
      
      else if (event is LibraryProductAddedToLibrary) {
        _analytics.logEvent(name: "add_wish_to_library", parameters: {
          "content_type" : "$_libraryView",
          "item_id" : event._product.barcode ?? event._product.title
        });

        yield _onProductAddedToLibrary(event._product);
      }
      
      else if (event is LibraryRefreshed) {
        _analytics.logEvent(name: "refresh_content", parameters: {
          "content_type" : "$_libraryView",
        });
        yield await _onRefreshed();
      }

      else {
        throw Exception("Unknown event ${event.runtimeType} in mapEventToState / LibraryBloc");
      }
    }
    
    catch (e) {
      _analytics.logEvent(name: "error", parameters: {
        "message" : "$e",
      });

      print(e);
      yield LibraryError();
    }
  }


  /// open library
  Future<LibraryLoaded> _onOpened(Category category, SubCategory subCategory, String orderBy, bool ascending) async {
    assert(state is LibraryLoading || state is LibraryLoaded);

    switch (_libraryView) {
      case LibraryView.Category:
        return _onCategoryOpened(category, subCategory, orderBy, ascending);

      case LibraryView.Favorites:
        return _onFavoritesOpened(orderBy, ascending);

      case LibraryView.Trash:
        return _onTrashOpened(orderBy, ascending);

      case LibraryView.WishList:
        return _onWishListOpened(orderBy, ascending);

      default:
        throw Exception("Unknown library view $_libraryView in _onLibraryOpended / LibraryBloc");
    }
  }

  Future<LibraryLoaded> _onCategoryOpened(Category category, SubCategory subCategory, String orderBy, bool ascending) async {
    List<Product> products = await _repository.getProductsByCategory(category, subCategory, orderBy, ascending);
    return LibraryLoaded(products, category, subCategory, orderBy, ascending);
  }

  Future<LibraryLoaded> _onFavoritesOpened(String orderBy, bool ascending) async {
    List<Product> products = await _repository.getProductsFromFavorites(orderBy, ascending);
    return LibraryLoaded(products, null, null, orderBy, ascending);
  }

  Future<LibraryLoaded> _onTrashOpened(String orderBy, bool ascending) async {
    List<Product> products = await _repository.getProductsFromTrash(orderBy, ascending);
    return LibraryLoaded(products, null, null, orderBy, ascending);
  }

  Future<LibraryLoaded> _onWishListOpened(String orderBy, bool ascending) async {
    List<Product> products = await _repository.getProductsFromWishList(orderBy, ascending);
    return LibraryLoaded(products, null, null, orderBy, ascending);
  }

  /// delete product with dismissible
  LibraryLoaded _onProductDeleted(Product product) {
    assert(state is LibraryLoaded);
    assert(_libraryView == LibraryView.Category);

    // update database and apply change to new state
    _repository.delete(product);
    List<Product> newProductList = List<Product>.from((state as LibraryLoaded).products);
    newProductList.remove(product);
    return (state as LibraryLoaded).copyWith(products: newProductList);
  }
  
  /// recover product with dismissible
  LibraryLoaded _onProductRecovered(Product product, int index) {
    assert(state is LibraryLoaded);
    assert(_libraryView == LibraryView.Category || _libraryView == LibraryView.Trash);

    // update database and apply change to new state
    _repository.recover(product);
    List<Product> newProductList = List<Product>.from((state as LibraryLoaded).products);

    // differentiate library view
    switch (_libraryView) {
      case (LibraryView.Category):
        newProductList.insert(index, product);
        break;

      case (LibraryView.Trash):
        newProductList.remove(product);
        break;

      default:
        throw Exception("Invalid library view $_libraryView in _onProductRecovered / LibraryBloc");
    }

    return (state as LibraryLoaded).copyWith(products: newProductList);
  }
  
  /// like product
  LibraryLoaded _onProductLiked(Product product) {
    assert(state is LibraryLoaded);

    // update database and apply change to new state
    _repository.like(product, true);
    List<Product> newProductList = List<Product>.from((state as LibraryLoaded).products);
    int index = newProductList.indexOf(product);
    newProductList.removeAt(index);
    newProductList.insert(index, product.copyWith(favorite: true));

    return (state as LibraryLoaded).copyWith(products: newProductList);
  }

  /// dislike product with dismissible
  LibraryLoaded _onProductDisliked(Product product) {
    assert(state is LibraryLoaded);
    assert(_libraryView == LibraryView.Favorites);

    // update database and apply change to new state
    _repository.like(product, false);
    List<Product> newProductList = List<Product>.from((state as LibraryLoaded).products);
    newProductList.remove(product);

    return (state as LibraryLoaded).copyWith(products: newProductList);
  }
  
  /// add product to library with dismissible
  LibraryLoaded _onProductAddedToLibrary(Product product) {
    assert(state is LibraryLoaded);
    assert(_libraryView == LibraryView.WishList);

    // update database and apply change to new state
    _repository.update(product.copyWith(wish: false));
    List<Product> newProductList = List<Product>.from((state as LibraryLoaded).products);
    newProductList.remove(product);

    return (state as LibraryLoaded).copyWith(products: newProductList);

  }
  
  /// refresh product list
  Future<LibraryLoaded> _onRefreshed() {
    assert(state is LibraryLoaded);

    // reload products from database
    LibraryLoaded oldState = state as LibraryLoaded;
    return _onOpened(oldState.category, oldState.subCategory, oldState.orderBy, oldState.ascending);
  }
  
}

/// Library Enum
enum LibraryView {
  Category,
  Favorites,
  Trash,
  WishList
}