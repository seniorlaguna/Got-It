import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';

/// Library Events
abstract class LibraryEvent extends Equatable {}
class LibrarySearched extends LibraryEvent {

  final String titleRegex;
  final Set<String> includedTags;
  final Set<String> excludedTags;

  LibrarySearched(this.titleRegex, this.includedTags, this.excludedTags);

  @override
  List<Object> get props => [titleRegex, includedTags, excludedTags];
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
  final String titleRegex;
  final Set<String> includedTags;
  final Set<String> excludedTags;
  LibraryLoaded(this.products, this.titleRegex, this.includedTags, this.excludedTags);

  LibraryLoaded copyWith({List<Product> products, String titleRegex, Set<String> includedTags, Set<String> excludedTags}) {
    return LibraryLoaded(
      products ?? this.products,
      titleRegex ?? this.titleRegex,
      includedTags ?? this.includedTags,
      excludedTags ?? this.excludedTags
    );
  }

  @override
  List<Object> get props => [products, titleRegex, includedTags, excludedTags];
}
class LibraryError extends LibraryState {
  @override
  List<Object> get props => [];
}

/// Library BLoC
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {

  final LibraryView _libraryView;
  final Repository _repository;

  LibraryBloc(this._libraryView, this._repository);

  @override
  LibraryState get initialState => LibraryLoading();

  @override
  Stream<LibraryState> mapEventToState(LibraryEvent event) async* {

    try {
      
      if (event is LibrarySearched) {
        yield LibraryLoading();
        yield await _onOpened(event.titleRegex, event.includedTags, event.excludedTags);
      }
      
      else if (event is LibraryProductDeleted) {
        yield _onProductDeleted(event._product);
      }
      
      else if (event is LibraryProductRecovered) {
        yield _onProductRecovered(event._product, event.index);
      }

      else if (event is LibraryRefreshed) {
        yield await _onRefreshed();
      }

      else {
        throw Exception("Unknown event ${event.runtimeType} in mapEventToState / LibraryBloc");
      }
    }
    
    catch (e) {
      print(e);
      yield LibraryError();
    }
  }


  /// open library
  Future<LibraryLoaded> _onOpened(String titleRegex, Set<String> includedTags, Set<String> excludedTags) async {
    assert(state is LibraryLoading || state is LibraryLoaded);
    return _onSearchOpened(titleRegex, includedTags, excludedTags);
  }

  Future<LibraryLoaded> _onSearchOpened(String titleRegex, Set<String> includedTags, Set<String> excludedTags) async {
    List<Product> products = await _repository.getProductsBySearch(titleRegex, includedTags, excludedTags);
    return LibraryLoaded(products, titleRegex, includedTags, excludedTags);
  }

  /// delete product with dismissible
  LibraryLoaded _onProductDeleted(Product product) {
    assert(state is LibraryLoaded);
    assert(_libraryView == LibraryView.Tag);

    // update database and apply change to new state
    _repository.delete(product);
    List<Product> newProductList = List<Product>.from((state as LibraryLoaded).products);
    newProductList.remove(product);
    return (state as LibraryLoaded).copyWith(products: newProductList);
  }
  
  /// recover product with dismissible
  LibraryLoaded _onProductRecovered(Product product, int index) {
    assert(state is LibraryLoaded);
    assert(_libraryView == LibraryView.Tag || _libraryView == LibraryView.Trash);

    // update database and apply change to new state
    _repository.restore(product);
    List<Product> newProductList = List<Product>.from((state as LibraryLoaded).products);

    // differentiate library view
    switch (_libraryView) {
      case (LibraryView.Tag):
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

  /// refresh product list
  Future<LibraryLoaded> _onRefreshed() {
    assert(state is LibraryLoaded);

    // reload products from database
    LibraryLoaded oldState = state as LibraryLoaded;
    return _onOpened(oldState.titleRegex, oldState.includedTags, oldState.excludedTags);
  }
  
}

/// Library Enum
enum LibraryView {
  Tag,
  Trash,
  Search
}