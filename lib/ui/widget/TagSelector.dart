import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/TagSelectorBloc.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';

class TagSelector extends StatelessWidget {
  final bool searchSelector;
  final double spacing = 3;
  final Repository _repository;
  final TagSelectorBloc _bloc;

  const TagSelector(this._repository, this._bloc,
      {Key key, this.searchSelector = false})
      : super(key: key);

  Future<void> _showDialog(BuildContext context, Set<String> selectedTags,
      Iterable<String> recommendations) async {
    String newTag = await showDialog(
        context: context,
        builder: (context) {
          return AddTagDialog(searchSelector, recommendations);
        });

    if (newTag != null && newTag.isNotEmpty) {
      Set<String> tmp = Set.from(selectedTags);
      tmp.add(newTag);
      _bloc.add(tmp);
    }
  }

  Widget getSearchTags(BuildContext context, Set<String> selectedTags) {
    return FutureBuilder(
        future: _repository.getTagsRanking(selectedTags),
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
                .map((e) => SelectableTag(e, selected: selectedTags.contains(e),
                        callback: () {
                      if (selectedTags.contains(e)) {
                        Set<String> tmp = Set.from(selectedTags);
                        tmp.remove(e);
                        _bloc.add(tmp);
                      } else {
                        Set<String> tmp = Set.from(selectedTags);
                        tmp.add(e);
                        _bloc.add(tmp);
                      }
                    }))
                .toList();

            if (ranking.length > 10) {
              children.add(AddTagButton(
                  callback: () => _showDialog(context, selectedTags,
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
          return Align(
              child: Text(
                  FlutterI18n.translate(context, "selector.no_tags_so_far")));
        });
  }

  Future<List<String>> _getRecommendsForEditing(
      Set<String> selectedTags) async {
    List<String> mostUsed = await _repository.getTagsRanking({});
    mostUsed.addAll(
        tagRecommendations.where((element) => !mostUsed.contains(element)));
    mostUsed.removeWhere((element) => categoryTags.contains(element));
    mostUsed.removeWhere((element) => selectedTags.contains(element));

    return mostUsed;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagSelectorBloc, Set<String>>(
      builder: (BuildContext context, Set<String> selectedTags) {
        // search selector
        if (searchSelector) {
          return getSearchTags(context, selectedTags);
        }

        // category already selected
        if (selectedTags.any((element) => categoryTags.contains(element))) {
          return FutureBuilder(
              future: _getRecommendsForEditing(selectedTags),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Text("");
                }

                List<String> ranking = snapshot.data as List<String>;

                List<Widget> children = selectedTags
                    .map((e) => SelectableTag(
                          e,
                          selected: true,
                          callback: () {
                            Set<String> tmp = Set.from(selectedTags);
                            tmp.remove(e);
                            _bloc.add(tmp);
                          },
                        ))
                    .toList();
                children.add(AddTagButton(
                    callback: () =>
                        _showDialog(context, selectedTags, ranking)));

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
              children: categoryTags
                  .map((e) => SelectableTag(
                        e,
                        selected: false,
                        callback: () {
                          Set<String> tmp = Set.from(selectedTags);
                          tmp.add(e);
                          _bloc.add(tmp);
                        },
                      ))
                  .toList());
        }
      },
    );
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
      tagRecommendations.addAll(widget.recommendedTags
          .where((element) => element.startsWith(value))
          .take(6));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(FlutterI18n.translate(context, "selector.more_tags")),
      contentPadding: EdgeInsets.all(8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            decoration: InputDecoration(
                hintText:
                    FlutterI18n.translate(context, "selector.type_your_tag")),
            onChanged: _updateRecommendations,
          ),
        ),
        Text(FlutterI18n.translate(context, "selector.recommendations")),
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
