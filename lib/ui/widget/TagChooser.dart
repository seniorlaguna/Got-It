import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/model/Product.dart';

class TagSelector extends StatefulWidget {
  final Set<String> tags;

  const TagSelector(this.tags, {Key key}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => TagSelectorState(tags);
}

class TagSelectorState extends State<TagSelector> {
  final Set<String> tags;

  TagSelectorState(this.tags);

  Set<String> getVisibleTags() {
    if (tags.every((element) => !mainTags.contains(element))) {
      return mainTags;
    }

    if (tags.every((element) => !colorTags.contains(element))) {
      return colorTags;
    }

    if (tags.every((element) => !brandTags.contains(element))) {
      return brandTags;
    }

    if (tags.every((element) => !toolTags.contains(element))) {
      return toolTags;
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {

    Set<String> visibleTags = Set<String>.of(tags)..addAll(getVisibleTags());

    return Wrap(
      direction: Axis.horizontal,
      children: visibleTags
          .map((String tag) => Padding(
              padding: const EdgeInsets.all(2.0),
              child: SelectableTag(tag, tags.contains(tag), () {

                setState(() {
                  if (tags.contains(tag)) {
                    tags.remove(tag);
                  }
                  else {
                    tags.add(tag);
                  }
                });

              })))
          .toList(),
    );
  }

}

class SelectableTag extends StatelessWidget {
  final String _tag;
  final bool _selected;
  final Function _onClick;

  static final TextStyle tagTextStyle = TextStyle(
      fontSize: 16, color: Colors.black38, fontWeight: FontWeight.w400);

  static final TextStyle tagSelectedTextStyle =
      TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400);

  const SelectableTag(this._tag, this._selected, this._onClick, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onClick,
      child: Container(
          decoration: BoxDecoration(
              color: _selected ? Colors.lightBlue : Colors.black12,
              borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text("#${FlutterI18n.translate(context, _tag)}",
                style: _selected ? tagSelectedTextStyle : tagTextStyle),
          )),
    );
  }
}
