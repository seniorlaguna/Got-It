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

  Widget getDropDownMenu(String tag, Set<String> tagList) {
    return PopupMenuButton(
        child: SelectableTag(tag, tags.contains(tag), () {}),
        itemBuilder: (_) => tagList
            .map((String tag) => PopupMenuItem(
                height: 24,
                child: SelectableTag(tag, tags.contains(tag), null),
                value: tag))
            .toList(),
        onSelected: (value) {
          setState(() {
            if (tags.contains(value)) {
              tags.remove(value);
            } else {
              tags.removeAll(tagList);
              tags.add(value);
            }
            if (mainTags.contains(value)) {
              Set<String> allTools = {};
              for (String key in toolTags.keys) {
                allTools.addAll(toolTags[key]);
              }
              tags.removeAll(allTools);
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    String category = tags.firstWhere((element) => mainTags.contains(element),
        orElse: () => "category");

    Set<String> allTools = {};
    for (String key in toolTags.keys) {
      allTools.addAll(toolTags[key]);
    }

    String toolType = tags.firstWhere((element) => allTools.contains(element),
        orElse: () => "tool type");

    /* String brand = tags.firstWhere((element) => brandTags.contains(element),
        orElse: () => "brand"); */

    String color = tags.firstWhere((element) => colorTags.contains(element),
        orElse: () => "color");

    EdgeInsets pad = const EdgeInsets.all(2.0);

    return Wrap(
      direction: Axis.horizontal,
      children: [
        Padding(
          padding: pad,
          child: getDropDownMenu(category, mainTags),
        ),
        Padding(
          padding: pad,
          child: getDropDownMenu(toolType, toolTags[category]),
        ),
        /* Padding(
          padding: pad,
          child: getDropDownMenu(brand, brandTags),
        ) */
        Padding(
          padding: pad,
          child: getDropDownMenu(color, colorTags),
        )
      ],
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
    return Container(
        decoration: BoxDecoration(
            color: _selected ? Theme.of(context).accentColor : Colors.black12,
            borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text("#${FlutterI18n.translate(context, _tag)}",
              style: _selected ? tagSelectedTextStyle : tagTextStyle),
        ));
  }
}
