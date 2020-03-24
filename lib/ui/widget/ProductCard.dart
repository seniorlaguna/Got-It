import 'package:flutter/material.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductViewer.dart';

class ProductCard extends StatelessWidget {

  final Product product;
  final Function onTap;

  const ProductCard(this.product, {Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = 80;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(product.title, style: TextStyle(fontSize: 20, color: Colors.black45),),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  product.wish ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.star, size: 28, color: Colors.yellowAccent),
                  ) : Container(),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(product.favorite ? Icons.favorite : Icons.favorite_border, size: 28, color: Color.fromRGBO(255, 0, 0, 0.3)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}