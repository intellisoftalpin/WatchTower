![Watch Tower](./graphics/banner.png)

# Watch Tower

Rocket client written in Flutter.

[![Framework](https://img.shields.io/badge/-Flutter-1a68d3?logo=flutter)](https://flutter.dev)

## Pipelines

Work in progress...

## Tables of Contents

* [How to generate app icons for Linux, Windows & Web](#how-to-generate-app-icons-for-linux-windows--web)
* [Contributing](#contributing)
* [Dependencies](#dependencies)

### How to generate app icons for Linux, Windows & Web

1. Uncomment `icons_launcher: ^2.0.6` in `pubspec.yaml`.
2. Run these commands:

```
$ flutter pub get
$ flutter pub run icons_launcher:create --path icons_launcher.yaml
```

3. (_optional_) In order to change platforms or add different icons for different platforms, please refer to [this package](https://pub.dev/packages/icons_launcher) or edit file icons_launcher.yaml directly.
4. Comment out `icons_launcher: ^2.0.6` in `pubspec.yaml`.

### Contributing

Check [CONTRIBUTING](.github/CONTRIBUTING.md) to know how to help with the project. Also check out our [Code of Conduct](./.github/CODE_OF_CONDUCT.md).

### Dependencies

Work in progress...
