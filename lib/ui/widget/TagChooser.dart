import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';

class TagSelector extends StatefulWidget {
  final Set<String> tags;
  final bool searchSelector;

  const TagSelector(this.tags, {Key key, this.searchSelector = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TagSelectorState(tags);
}

class TagSelectorState extends State<TagSelector> {
  final Set<String> tags;
  final double spacing = 3;
  Repository _repository;

  TagSelectorState(this.tags);

  @override
  void initState() {
    super.initState();
    _repository = RepositoryProvider.of<Repository>(context);
  }

  Future<void> _showDialog(Iterable<String> recommendations) async {
    String newTag = await showDialog(
        context: context,
        builder: (context) {
          return AddTagDialog(widget.searchSelector, recommendations);
        });

    if (newTag != null && newTag.isNotEmpty) {
      setState(() {
        tags.add(newTag);
      });
    }
  }

  Widget getSearchTags(BuildContext context) {
    return FutureBuilder(
        future: _repository.getTagsRanking(tags),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState != ConnectionState.done) {
            return Text("");
          }

          List<String> ranking = snapshot.data as List<String>;

          // Data
          if (ranking.isNotEmpty) {
            List<Widget> children = ranking
                .getRange(0, min(10, ranking.length))
                .map((e) =>
                    SelectableTag(e, selected: tags.contains(e), callback: () {
                      if (tags.contains(e)) {
                        setState(() {
                          tags.remove(e);
                        });
                      } else {
                        setState(() {
                          tags.add(e);
                        });
                      }
                    }))
                .toList();

            if (ranking.length > 10) {
              children.add(AddTagButton(
                  callback: () => _showDialog(
                      ranking.getRange(10, ranking.length - 1).toSet())));
            }

            return Wrap(
                runSpacing: spacing,
                spacing: spacing,
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: children);
          }

          // No Data
          return Align(child: Text("You used no tags so far..."));
        });
  }

  Future<List<String>> _getRecommendsForEditing() async {
    List<String> mostUsed = await _repository.getTagsRanking({});
    mostUsed.addAll(["Marke A", "Marke B", "Marke C"]);
    mostUsed.removeWhere((element) => mainTags.contains(element));
    mostUsed.removeWhere((element) => tags.contains(element));

    return mostUsed;
  }

  @override
  Widget build(BuildContext context) {
    // search selector
    if (widget.searchSelector) {
      return getSearchTags(context);
    }

    // category already selected
    if (tags.any((element) => mainTags.contains(element))) {
      return FutureBuilder(
          future: _getRecommendsForEditing(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Text("");
            }

            List<String> ranking = snapshot.data as List<String>;

            List<Widget> children = tags
                .map((e) => SelectableTag(
                      e,
                      selected: true,
                      callback: () {
                        setState(() {
                          tags.remove(e);
                        });
                      },
                    ))
                .toList();
            children.add(AddTagButton(callback: () => _showDialog(ranking)));

            return Wrap(
                runSpacing: spacing,
                spacing: spacing,
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: children);
          });
    }
    // no category selected
    else {
      return Wrap(
          runSpacing: spacing,
          spacing: spacing,
          direction: Axis.horizontal,
          children: mainTags
              .map((e) => SelectableTag(
                    e,
                    selected: false,
                    callback: () {
                      setState(() {
                        tags.add(e);
                      });
                    },
                  ))
              .toList());
    }
  }
}

// Tags
class SelectableTag extends StatelessWidget {
  static final TextStyle _tagTextStyle = TextStyle(
      fontSize: 16, color: Color(0xffdc9a9b), fontWeight: FontWeight.w700);

  final String _text;
  final Function callback;
  final bool selected;

  const SelectableTag(this._text, {Key key, this.callback, this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Text only
    if (selected == null) {
      return Text("#${FlutterI18n.translate(context, _text)}",
          style: _tagTextStyle);
    }

    // Colors
    final Color backgroundColor =
        selected ? Theme.of(context).accentColor : Colors.black12;
    final Color textColor = selected ? Colors.white : Colors.black38;
    final BoxDecoration boxDecoration = BoxDecoration(
        color: backgroundColor, borderRadius: BorderRadius.circular(8.0));
    final TextStyle textStyle =
        TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w400);
    final EdgeInsets padding = EdgeInsets.symmetric(vertical: 1, horizontal: 2);

    // Selected most cases
    if (selected) {
      return GestureDetector(
        onTap: callback,
        child: Container(
          padding: padding,
          decoration: boxDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("#${FlutterI18n.translate(context, _text)}",
                  style: textStyle),
              Icon(Icons.clear, color: textColor, size: 18)
            ],
          ),
        ),
      );
    }

    // Not Selected
    else {
      return GestureDetector(
        onTap: callback,
        child: Container(
          padding: padding,
          decoration: boxDecoration,
          child: Text("#${FlutterI18n.translate(context, _text)}",
              style: textStyle),
        ),
      );
    }
  }
}

class AddTagButton extends SelectableTag {
  AddTagButton({Function callback}) : super("+", callback: callback);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: super.callback,
      child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.black12, borderRadius: BorderRadius.circular(16)),
          child: Icon(
            Icons.more_horiz,
            color: Colors.black38,
            size: 14,
          )),
    );
  }
}

// Add Tag Dialog
class AddTagDialog extends StatefulWidget {
  final bool search;
  final Iterable<String> recommendedTags;

  const AddTagDialog(this.search, this.recommendedTags, {Key key})
      : super(key: key);

  @override
  _AddTagDialogState createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  final double spacing = 4;

  Set<String> tagRecommendations = {};

  @override
  void initState() {
    super.initState();
    tagRecommendations.addAll(widget.recommendedTags.take(6));
  }

  // smart recommends
  void _updateRecommendations(String value) {
    setState(() {
      tagRecommendations.clear();
      if (!widget.search && value.isNotEmpty) tagRecommendations.add(value);
      tagRecommendations.addAll(
          widget.recommendedTags.where((element) => element.startsWith(value)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("more tags"),
      contentPadding: EdgeInsets.all(8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            decoration: InputDecoration(hintText: "type your tag..."),
            onChanged: _updateRecommendations,
          ),
        ),
        Text("recommendations"),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: tagRecommendations
                .map((e) => SelectableTag(
                      e,
                      selected: false,
                      callback: () {
                        Navigator.pop(context, e);
                      },
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}
