import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/data/Categories.dart';
import 'package:got_it/model/Category.dart';
import 'package:got_it/ui/screen/CategoryViewer.dart';
import 'package:got_it/ui/screen/FavoritesViewer.dart';
import 'package:got_it/ui/screen/TrashViewer.dart';
import 'package:got_it/ui/widget/ImageLoader.dart';
import 'package:got_it/ui/widget/MyIconButton.dart';

class CategoriesScreen extends StatelessWidget {

  final List<_CategoryButtonData> _categoryData = Categories.map((Category category) {
    return _CategoryButtonData((BuildContext context) => CategoryViewer.start(context, category),
        category.title,
        category.iconData
    );
  }).toList()
    ..add(_CategoryButtonData((BuildContext context) => FavoritesViewer.start(context), "category.favorites", Icons.favorite))
    ..add(_CategoryButtonData((BuildContext context) => TrashViewer.start(context), "category.trash", Icons.delete))
  ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: _getAppBar(context)
          ),

          Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: _getBody(context)
          )


        ],
      ),
    );
  }

  Widget _getAppBar(BuildContext context) {
    return Stack(
      children: [
        ImageLoader(null, fallbackAsset: "assets/library.jpg"),
        AppBar(
          title: Text(FlutterI18n.translate(context, "main_screen.library")),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget _getBody(BuildContext context) {
    return GridView.count(
      childAspectRatio: 2 / 1,
        crossAxisCount: 2,
      children: _categoryData.map((_CategoryButtonData data) {
        return MyIconButton(
          () => data.onClick(context),
          data.icon,
          FlutterI18n.translate(context, data.title)
        );
      }).toList(),
    );
  }

}

class _CategoryButtonData {
  final Function(BuildContext) onClick;
  final String title;
  final IconData icon;

  _CategoryButtonData(this.onClick, this.title, this.icon);
}
