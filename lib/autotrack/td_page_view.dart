import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:thinking_analytics/autotrack/td_autotrack.dart';
import 'package:thinking_analytics/autotrack/td_autotrack_config.dart';
import 'package:thinking_analytics/td_analytics.dart';

class TDNavigatorObserver extends NavigatorObserver {
  static List<NavigatorObserver> wrap(
      List<NavigatorObserver>? navigatorObservers) {
    if (navigatorObservers == null || navigatorObservers.isEmpty) {
      return [TDNavigatorObserver()];
    }
    bool found = false;
    List<NavigatorObserver> removeList = [];
    for (NavigatorObserver observer in navigatorObservers) {
      if (observer is TDNavigatorObserver) {
        if (found) {
          removeList.add(observer);
        }
        found = true;
      }
    }
    for (NavigatorObserver observer in removeList) {
      navigatorObservers.remove(observer);
    }
    if (!found) {
      navigatorObservers.insert(0, TDNavigatorObserver());
    }
    return navigatorObservers;
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    try {
      this._findElement(route, (element) {
        TDPageStack.instance.push(route, element, previousRoute);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    try {
      TDPageStack.instance.pop(route, previousRoute);
    } catch (e) {
      print(e);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    try {
      TDPageStack.instance.remove(route, previousRoute);
    } catch (e) {
      print(e);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    try {
      this._findElement(newRoute!, (element) {
        TDPageStack.instance.replace(newRoute, element, oldRoute);
      });
    } catch (e) {
      print(e);
    }
  }

  void _findElement(Route route, Function(Element) result) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (route is ModalRoute) {
        ModalRoute pageRoute = route;
        TDElementUtil.walk(pageRoute.subtreeContext, (element, parent) {
          if (parent != null && parent.widget is Semantics) {
            result(element);
            return false;
          }
          return true;
        });
      } else if (TDAutoTrackManager.instance.config.useCustomRoute) {
        List<TDAutoTrackPageConfig> pageConfigs =
            TDAutoTrackManager.instance.config.pageConfigs;
        if (pageConfigs.isEmpty) {
          return;
        }
        Element? lastPageElement;
        TDElementUtil.walk(route.navigator?.context, (element, parent) {
          if (pageConfigs.last.isPageWidget(element.widget)) {
            lastPageElement = element;
            return false;
          }
          return true;
        });
        if (lastPageElement != null) {
          result(lastPageElement!);
        }
      }
    });
  }
}

enum _TDPageRouteType { push, pop, remove, replace }

class TDPageStack {
  static final instance = TDPageStack();
  LinkedList<_TDPage> _pages = LinkedList<_TDPage>();
  _TDPageTask _task = _TDPageTask();

  void push(Route route, Element element, Route? previousRoute) {
    _TDPage page = _TDPage.create(route, element);
    _pages.add(page);
    _task.addPush(page, page.previous);
  }

  void pop(Route route, Route? previousRoute) {
    if (_pages.isEmpty) {
      return;
    }
    _TDPage? page = _findPage(route);
    if (page != null) {
      _task.addPop(page, page.previous);
    }
    _removeAllAfter(page);
  }

  void remove(Route route, Route? previousRoute) {
    if (_pages.isEmpty) {
      return;
    }
    _TDPage? page = _findPage(route);
    if (page != null) {
      _pages.remove(page);
    }
  }

  void replace(Route newRoute, Element newElement, Route? oldRoute) {
    _TDPage newPage = _TDPage.create(newRoute, newElement);
    _TDPage? oldPage;
    if (oldRoute != null) {
      oldPage = _findPage(oldRoute);
      _removeAllAfter(oldPage);
    }
    _pages.add(newPage);
    _task.addReplace(newPage, oldPage);
  }

  _TDPage? currentPage() {
    return _pages.isEmpty ? null : _pages.last;
  }

  _TDPage? _findPage(Route route) {
    if (_pages.isEmpty) {
      return null;
    }
    _TDPage? lastPage = _pages.last;
    while (lastPage != null) {
      if (lastPage.route == route) {
        return lastPage;
      }
      lastPage = lastPage.previous;
    }
    return null;
  }

  _removeAllAfter(_TDPage? page) {
    while (page != null) {
      _pages.remove(page);
      page = page.next;
    }
  }
}

class _TDPage extends LinkedListEntry<_TDPage> {
  _TDPage._({
    required this.info,
    required this.route,
    required this.element,
  });

  final TDPageInfo info;
  final Route route;
  final Element element;

  factory _TDPage.create(Route route, Element element) {
    return _TDPage._(
      info: TDPageInfo.getInfo(route, element),
      route: route,
      element: element,
    );
  }
}

class TDPageInfo {
  TDPageInfo._();

  String title = '';
  String screenName = '';
  bool ignore = false;
  Map<String, dynamic>? properties;

  factory TDPageInfo.getInfo(Route route, Element element) {
    TDAutoTrackPageConfig pageConfig =
        TDAutoTrackManager.instance.findPageConfig(element.widget);
    TDPageInfo info = TDPageInfo._();
    info.title = pageConfig.title ?? (TDElementUtil.findTitle(element) ?? '');
    info.screenName =
        pageConfig.screenName ?? element.widget.runtimeType.toString();
    info.ignore = pageConfig.ignore;
    info.properties = pageConfig.properties;
    return info;
  }
}

class _TDPageTask {
  List<_TDPageTaskData> _taskList = [];
  bool _isTaskRunning = false;

  void addPush(_TDPage page, _TDPage? previousPage) {
    _TDPageTaskData taskData =
        _TDPageTaskData(page: page, type: _TDPageRouteType.push);
    taskData.previousPage = previousPage;
    _taskList.add(taskData);
    startTask();
  }

  void addPop(_TDPage page, _TDPage? previousPage) {
    _TDPageTaskData taskData =
        _TDPageTaskData(page: page, type: _TDPageRouteType.pop);
    taskData.previousPage = previousPage;
    _taskList.add(taskData);
    startTask();
  }

  void addReplace(_TDPage page, _TDPage? previousPage) {
    _TDPageTaskData taskData =
        _TDPageTaskData(page: page, type: _TDPageRouteType.replace);
    taskData.previousPage = previousPage;
    _taskList.add(taskData);
    startTask();
  }

  void addRemove(_TDPage page, _TDPage? previousPage) {}

  void startTask() {
    if (_isTaskRunning) {
      return;
    }
    _isTaskRunning = true;
    Future.delayed(Duration(milliseconds: 30), () {
      _runTask();
    });
  }

  void _runTask() {
    if (_taskList.isEmpty) {
      _isTaskRunning = false;
      return;
    }
    List list = _taskList.sublist(0);
    _TDPage? enterPage, leavePage;
    _taskList.clear();
    for (_TDPageTaskData data in list) {
      switch (data.type) {
        case _TDPageRouteType.push:
          if (leavePage == null) {
            leavePage = data.previousPage;
          }
          enterPage = data.page;
          break;
        case _TDPageRouteType.pop:
          if (leavePage == null) {
            leavePage = data.page;
          }
          if (enterPage == null || enterPage == data.page) {
            enterPage = data.previousPage;
          }
          break;
        case _TDPageRouteType.replace:
          if (leavePage == null) {
            leavePage = data.previousPage;
          }
          if (enterPage == null || enterPage == data.previousPage) {
            enterPage = data.page;
          }
          break;
        case _TDPageRouteType.remove:
          break;
      }
    }
    if (enterPage == leavePage) {
      _isTaskRunning = false;
      return;
    }
    if (enterPage != null && !enterPage.info.ignore) {
      if (TDAutoTrackManager.instance.pageViewEnabled) {
        Map<String, dynamic> properties = Map();
        properties["#title"] = enterPage.info.title;
        properties["#screen_name"] = enterPage.info.screenName;
        if (leavePage != null) {
          properties["#referrer"] = leavePage.info.screenName;
        }
        properties.addAll(enterPage.info.properties ?? {});
        properties.addAll(TDAutoTrackManager.instance.autoTrackProperties ?? {});
        TDAnalytics.track("ta_app_view", properties: properties);
      }
    }
    _isTaskRunning = false;
  }
}

class _TDPageTaskData {
  _TDPageTaskData({
    required this.page,
    required this.type,
  });

  final _TDPageRouteType type;
  final _TDPage page;
  _TDPage? previousPage;
}
