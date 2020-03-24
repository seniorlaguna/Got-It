import 'package:equatable/equatable.dart';

class CarouselItem extends Equatable {
  final String imagePath;
  final String url;

  @override
  List<Object> get props => [imagePath, url];

  CarouselItem(this.imagePath, this.url);
}