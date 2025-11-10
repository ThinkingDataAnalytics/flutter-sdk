import 'package:flutter/widgets.dart';

class TDElementKey extends Key {
  final String key;
  final Map<String, dynamic>? properties;
  final bool isIgnore;

  TDElementKey(this.key, {this.properties, this.isIgnore = false})
      : super.empty();
}

class TDAutoTrackConfig {
  TDAutoTrackConfig({
    this.pageConfigs = const [],
    this.useCustomRoute = false,
  });

  List<TDAutoTrackPageConfig> pageConfigs;
  bool useCustomRoute;
}

class TDAutoTrackPageConfig<T extends Widget> {
  String? title;
  String? screenName;
  Map<String, dynamic>? properties;
  bool ignore;

  TDAutoTrackPageConfig({
    String? title,
    String? screenName,
    Map<String, dynamic>? properties,
    bool ignore = false,
  }) : ignore = ignore {
    this.title = title;
    this.screenName = screenName;
    this.properties = properties;
  }

  bool isPageWidget(Widget pageWidget) => pageWidget is T;
}
