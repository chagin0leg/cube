import 'package:cube/theme/color_filter_provider.dart';
import 'package:flutter/material.dart';

class ThemeButton extends StatelessWidget {
  static const List<String> _themes = [
    'Light',
    'Dark',
    'Marina',
    'Radioactive',
    'Bloody',
    'Saint',
    'Sporty',
  ];

  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: ColorFilterProvider.of(context).currentTheme,
      alignment: Alignment.centerLeft,
      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
      style: Theme.of(context).textTheme.titleSmall,
      elevation: 0,
      itemHeight: 50,
      menuMaxHeight: 150,
      menuWidth: 150,
      items: [
        for (String element in _themes)
          DropdownMenuItem(value: element, child: Text(element)),
      ],
      onChanged: (value) {
        if (value != null) {
          ColorFilterProvider.of(context).setTheme(value);
        }
      },
    );
  }
}
