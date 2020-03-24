import 'package:equatable/equatable.dart';
import 'package:got_it/model/CarouselItem.dart';

abstract class MainEvent extends Equatable {}
class MainOpen extends MainEvent {
  @override
  List<Object> get props => [];
}

abstract class MainState extends Equatable {}
class MainDefault extends MainState {
  @override
  List<Object> get props => [];
}
class MainCarousel extends MainState {
  final List<CarouselItem> items;

  @override
  List<Object> get props => [items];

  MainCarousel(this.items);
}