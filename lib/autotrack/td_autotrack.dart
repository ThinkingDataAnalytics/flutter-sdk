import 'package:flutter/widgets.dart';
import 'package:thinking_analytics/autotrack/td_autotrack_config.dart';
import 'package:thinking_analytics/autotrack/td_element_click.dart';

class TDAutoTrackManager {
  static final TDAutoTrackManager instance = TDAutoTrackManager._();

  TDAutoTrackManager._();

  TDAutoTrackConfig _config = TDAutoTrackConfig();
  Map<String, dynamic>?  _autoTrackEventProperties;
  bool _enableElementClick = false;
  bool _enablePageView = false;

  TDAutoTrackConfig get config => _config;

  Map<String, dynamic>? get autoTrackProperties => _autoTrackEventProperties;

  set config(TDAutoTrackConfig config) {
    _config = config;
  }

  set autoTrackProperties(Map<String, dynamic>? config) {
    autoTrackProperties = config;
  }

  void enablePageView(bool enable) {
    _enablePageView = enable;
  }

  bool get pageViewEnabled => _enablePageView;

  void enableElementClick(bool enable) {
    _enableElementClick = enable;
    if (enable) {
      TDPointerEventClick.instance.startClickListener();
    } else {
      TDPointerEventClick.instance.stopClickListener();
    }
  }

  bool get elementClickEnabled => _enableElementClick;

  TDAutoTrackPageConfig findPageConfig(Widget pageWidget) {
    return _config.pageConfigs.firstWhere(
        (element) => element.isPageWidget(pageWidget),
        orElse: () => TDAutoTrackPageConfig());
  }
}

typedef TDElementWalker = bool Function(Element child, Element? parent);

class TDElementUtil {
  static void walk(BuildContext? context, TDElementWalker walker) {
    if (context == null) {
      return;
    }
    context.visitChildElements((element) {
      if (walker(element, null)) {
        walkElement(element, walker);
      }
    });
  }

  static void walkElement(Element element, TDElementWalker walker) {
    element.visitChildren((child) {
      if (walker(child, element)) {
        walkElement(child, walker);
      }
    });
  }

  static String? findTitle(Element element) {
    String? title;
    walkElement(element, (child, _) {
      if (child.widget is NavigationToolbar) {
        NavigationToolbar toolBar = child.widget as NavigationToolbar;
        if (toolBar.middle == null) {
          return false;
        }

        if (toolBar.middle is Text) {
          title = (toolBar.middle as Text).data;
          return false;
        }

        int layoutIndex = 0;
        if (toolBar.leading != null) {
          layoutIndex += 1;
        }
        title = findTextsInMiddle(child, layoutIndex);
        return false;
      }
      return true;
    });
    return title;
  }

  static String? findTextsInMiddle(Element element, int layoutIndex) {
    String? text;
    int index = 0;
    walkElement(element, ((child, _) {
      if (child.widget is LayoutId) {
        if (index == layoutIndex) {
          text = findTexts(child).join('');
          return false;
        }
        index += 1;
      }
      return true;
    }));
    return text;
  }

  static List<String> findTexts(Element element) {
    List<String> list = [];
    walkElement(element, ((child, _) {
      if (child.widget is Text) {
        String? text = (child.widget as Text).data;
        if (text != null) {
          list.add(text);
        }
        return false;
      }
      return true;
    }));
    return list;
  }

  static Element? findAncestorElementOfWidgetType<T extends Widget>(Element? element) {
    if (element == null) {
      return null;
    }

    Element? target;
    element.visitAncestorElements((parent) {
      if (parent.widget is T) {
        target = parent;
        return false;
      }
      return true;
    });
    return target;
  }
}
