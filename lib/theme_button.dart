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

  static String _currentTheme = 'Light';

  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: _currentTheme,
      alignment: Alignment.centerLeft,
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
        List<double> redChannel = [1, 0, 0, 0, 0];
        List<double> greenChannel = [0, 1, 0, 0, 0];
        List<double> blueChannel = [0, 0, 1, 0, 0];
        List<double> alphaChannel = [0, 0, 0, 1, 0];

        switch (value) {
          case 'Dark':
            _currentTheme = 'Dark';
            redChannel = [-1, 0, 0, 0, 255];
            greenChannel = [0, -1, 0, 0, 255];
            blueChannel = [0, 0, -1, 0, 255];
            break;
          case 'Marina':
            _currentTheme = 'Marina';
            redChannel = [0, 0, 0, 0, 0];
            greenChannel = [0, 0, 0, 0, 0];
            blueChannel = [0, 0, -1, 0, 255];
            break;
          case 'Radioactive':
            _currentTheme = 'Radioactive';
            redChannel = [-0.7, 0, 0.3, 0, 0];
            greenChannel = [0.2, 0, 0.2, 0, 0];
            blueChannel = [-0.5, 0, 0.7, 0, 0];
            break;
          case 'Bloody':
            _currentTheme = 'Bloody';
            greenChannel = [0.2, 0, 0, 0, 0];
            blueChannel = [0.2, 0, 0, 0, 0];
            break;
          case 'Saint':
            _currentTheme = 'Saint';
            redChannel = [0.7, 0, 0.3, 0, 0];
            greenChannel = [0.2, 0, 0.1, 0, 0];
            blueChannel = [0.5, 0, 0.7, 0, 0];
          case 'Sporty':
            _currentTheme = 'Sporty';
            redChannel = [0.7, 0, 0.3, 0, 0];
            greenChannel = [0.2, 0, 0.1, 0, 0];
            blueChannel = [-0.5, 0, 0.7, 0, 0];
          case 'Light':
          default:
            _currentTheme = 'Light';
            break;
        }

        ColorFilterProvider.of(context).setMatrix(
          alphaChannel: alphaChannel,
          blueChannel: blueChannel,
          greenChannel: greenChannel,
          redChannel: redChannel,
        );
      },
    );
  }
}
