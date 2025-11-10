import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:thinking_analytics/autotrack/td_autotrack.dart';
import 'package:thinking_analytics/autotrack/td_autotrack_config.dart';
import 'package:thinking_analytics/autotrack/td_page_view.dart';
import 'package:thinking_analytics/td_analytics.dart';

class _TDTapGestureRecognizer extends TapGestureRecognizer {
  _TDTapGestureRecognizer({Object? debugOwner}) : super(debugOwner: debugOwner);

  PointerDownEvent? lastPointerDownEvent;
  int rejectPointer = 0;

  @override
  void addPointer(PointerDownEvent event) {
    lastPointerDownEvent = event;
    super.addPointer(event);
  }

  @override
  void rejectGesture(int pointer) {
    if (lastPointerDownEvent?.pointer == pointer) {
      lastPointerDownEvent = null;
    }
    rejectPointer = pointer;
    super.rejectGesture(pointer);
  }

  void checkPointerUpEvent(PointerUpEvent upEvent) {
    if (lastPointerDownEvent == null) {
      return;
    }
    Offset downEventPosition = lastPointerDownEvent!.position;
    Offset upEventPosition = upEvent.position;
    double offset = (downEventPosition.dx - upEventPosition.dx).abs() +
        (downEventPosition.dy - upEventPosition.dy).abs();
    if (offset > 30) {
      rejectGesture(upEvent.pointer);
    }
  }
}

class TDPointerEventClick {
  static TDPointerEventClick instance = TDPointerEventClick._();

  TDPointerEventClick._();

  _TDTapGestureRecognizer _tapGestureRecognizer = _TDTapGestureRecognizer();

  bool _isStart = false;

  void startClickListener() {
    if (_isStart) return;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_pointerRoute);
    _tapGestureRecognizer.dispose();
    _isStart = true;
  }

  void stopClickListener() {
    if (!_isStart) return;
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_pointerRoute);
    _tapGestureRecognizer.dispose();
    _isStart = false;
  }

  void _pointerRoute(PointerEvent event) {
    try {
      if (event is PointerDownEvent) {
        _tapGestureRecognizer.addPointer(event);
      } else if (event is PointerUpEvent) {
        _tapGestureRecognizer.checkPointerUpEvent(event);
        PointerDownEvent? pointerDownEvent =
            _tapGestureRecognizer.lastPointerDownEvent;
        if (event.pointer != _tapGestureRecognizer.rejectPointer &&
            pointerDownEvent != null) {
          _checkElementAndTrack(pointerDownEvent, event);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _checkElementAndTrack(
      PointerDownEvent downEvent, PointerUpEvent upEvent) {
    final currentPage = TDPageStack.instance.currentPage();
    if (currentPage == null) {
      return;
    }
    LinkedList<_TDHitEntry> hits = LinkedList();
    TDElementUtil.walkElement(currentPage.element, (child, _) {
      if (child is RenderObjectElement && child.renderObject is RenderBox) {
        RenderBox renderBox = child.renderObject as RenderBox;
        if (!renderBox.hasSize) {
          return false;
        }
        Offset localPosition = renderBox.globalToLocal(upEvent.position);
        if (!renderBox.size.contains(localPosition)) {
          return false;
        }
        if (renderBox is RenderPointerListener) {
          hits.add(_TDHitEntry(child));
        }
      }
      return true;
    });
    if (hits.isEmpty) {
      return;
    }
    _TDHitEntry? entry = hits.last;
    Element? gestureElement;
    while (entry != null) {
      gestureElement =
          TDElementUtil.findAncestorElementOfWidgetType<GestureDetector>(
              entry.element);
      if (gestureElement != null) {
        break;
      }
      entry = entry.previous;
    }
    if (gestureElement != null &&
        TDAutoTrackManager.instance.elementClickEnabled) {
      Element element = TDElementPath.createFrom(element: gestureElement, pageElement: currentPage.element).element;
      bool isIgnore = false;
      Key? key = element.widget.key;
      Map<String, dynamic> properties = Map();
      if (key is TDElementKey) {
        isIgnore = key.isIgnore;
        properties["#element_id"] = key.key;
        properties.addAll(key.properties ?? {});
      }
      if (isIgnore) {
        return;
      }
      properties["#title"] = currentPage.info.title;
      properties["#screen_name"] = currentPage.info.screenName;
      properties["#element_type"] = element.widget.runtimeType.toString();
      properties["#element_content"] = TDElementUtil.findTexts(element).join('-');
      properties.addAll(TDAutoTrackManager.instance.autoTrackProperties ?? {});
      TDAnalytics.track("ta_app_click",properties: properties);
    }
  }
}

class _TDHitEntry extends LinkedListEntry<_TDHitEntry> {
  _TDHitEntry(this.element);

  final Element element;
}

class TDElementPath{
  TDElementPath._(this._element);
  factory TDElementPath.createFrom({
    required Element element,
    required Element pageElement,
  }) {
    TDElementPath path = TDElementPath._(element);
    path._element = element;
    bool searchTarget = true;
    element.visitAncestorElements((parent) {
      if (parent.widget is GestureDetector) {
        searchTarget = false;
      }
      if (searchTarget && _TDPathConstants.levelSet.contains(parent.widget.runtimeType)) {
        path._element = parent;
      }
      if (parent == pageElement) {
        return false;
      }
      return true;
    });
    return path;
  }
  Element _element;
  Element get element => _element;
}

class _TDPathConstants {
  static final Set<Type> levelSet = {
    IconButton,
    TextButton,
    InkWell,
    ElevatedButton,
    ListTile,
  };
}
