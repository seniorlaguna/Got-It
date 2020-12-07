import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductListScreen.dart';
import 'package:got_it/ui/widget/TagCard.dart';

import 'SearchScreen.dart';

class TagsScreen extends StatelessWidget {
  static Future<dynamic> start(BuildContext context) {
    return Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => TagsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _getAppBar(context),
        body: _getBody(context),
      ),
    );
  }

  Widget _getAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        FlutterI18n.translate(context, "main_screen.my_cosmetics"),
        style: TextStyle(color: Colors.black),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => SearchScreen.start(context),
        )
      ],
      leading: GestureDetector(
        child: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    List<String> tags = List.of(categoryTags);
    tags.insert(1, favoriteTag);
    tags.insert(8, deleteTag);

    // TODO: PERFORMANCE IMPROVEMENTS

    return AnimationLimiter(
      child: StaggeredGridView.countBuilder(
          crossAxisCount: 4,
          itemCount: tags.length,
          itemBuilder: (BuildContext context, int index) =>
              AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: Duration(milliseconds: 400),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: TagCard(
                          tags[index],
                          [1, 8].contains(index)
                              ? "assets/tags/empty.jpg"
                              : "assets/tags/${tags[index]}.jpg",
                          () => getOnClickFunction(context, index, tags[index]),
                          [1, 8].contains(index),
                          [0, 4, 5].contains(index)
                              ? Theme.of(context).accentColor
                              : Colors.white),
                    ),
                  )),
          staggeredTileBuilder: (int index) =>
              StaggeredTile.count(2, index == 1 || index == 8 ? 1 : 2)),
    );
  }

  void getOnClickFunction(BuildContext context, int index, String tag) {
    if (index == 1) {
      ProductListScreen.openFavorites(context);
    } else if (index == 8) {
      ProductListScreen.openTrash(context);
    } else {
      ProductListScreen.openTag(context, tag);
    }
  }
}
