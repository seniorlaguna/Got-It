import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';

/// Library Events
abstract class ProductEvent extends Equatable {
  final Product product;

  ProductEvent(this.product);
}

class ProductChangedEvent extends ProductEvent {
  final bool submit;

  ProductChangedEvent(Product product, this.submit) : super(product);

  @override
  List<Object> get props => [product];
}

class ProductOpenedEvent extends ProductEvent {
  final bool edit;

  ProductOpenedEvent(Product product, this.edit) : super(product);

  @override
  List<Object> get props => [product, edit];
}

/// Library States
abstract class ProductState extends Equatable {
  final Product product;

  ProductState(this.product);
}

class ProductLoadingState extends ProductState {
  ProductLoadingState() : super(Product.empty());

  @override
  List<Object> get props => [];
}

class ProductViewingState extends ProductState {
  ProductViewingState(Product product) : super(product);

  @override
  List<Object> get props => [product];
}

class ProductEditingState extends ProductState {
  ProductEditingState(Product product) : super(product);

  @override
  List<Object> get props => [product];
}

class ProductErrorState extends ProductState {
  ProductErrorState(Product product) : super(product);

  @override
  List<Object> get props => [product];
}

/// Library BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final Repository _repository;

  ProductBloc(this._repository);

  @override
  ProductState get initialState => ProductLoadingState();

  @override
  Stream<ProductState> mapEventToState(ProductEvent event) async* {
    try {
      if (event is ProductOpenedEvent) {
        yield (event.edit
            ? ProductEditingState(event.product)
            : ProductViewingState(event.product));
      } else if (event is ProductChangedEvent) {
        assert(state is ProductViewingState || state is ProductEditingState);

        // only write to disk if product already has an id or
        // it's submitted
        int id;
        if (event.product.id != null || event.submit) {
          id = await _repository.insertOrUpdate(event.product);
        }

        if (state is ProductViewingState) {
          yield ProductViewingState(event.product.copyWith(id: id));
        } else if (state is ProductEditingState) {
          if (event.submit) {
            yield ProductViewingState(event.product.copyWith(id: id));
          } else {
            yield ProductEditingState(event.product.copyWith(id: id));
          }
        }
      } else {
        throw Exception(
            "Unknown event ${event.runtimeType} in mapEventToState / ProductBloc");
      }
    } catch (e) {
      print(e);
      yield ProductErrorState(event.product);
    }
  }
}
