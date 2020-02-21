// Copyright (c) 2019/12/02, 11:28:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../extension/thrio_stateful_widget.dart';
import '../logger/thrio_logger.dart';
import '../registry/registry_map.dart';
import 'thrio_navigator_observer.dart';
import 'thrio_navigator_receiver.dart';
import 'thrio_navigator_sender.dart';
import 'thrio_page_route.dart';
import 'thrio_route_settings.dart';

/// A widget that manages a set of child widgets with a stack discipline.
///
class ThrioNavigator extends StatefulWidget {
  const ThrioNavigator({
    Key key,
    ThrioNavigatorObserver observer,
    this.child,
  })  : _observer = observer,
        super(key: key);

  final Navigator child;

  final ThrioNavigatorObserver _observer;

  static final _channel = ThrioChannel(channel: '__thrio_app__');

  static final _pageSubject = ThrioNavigatorSender(_channel);

  static final _pageObserver = ThrioNavigatorReceiver(_channel);

  static final _pageBuilders = RegistryMap<String, ThrioPageBuilder>();

  /// Push a page with `url` onto `ThrioNavigator`.
  ///
  static Future<bool> push({
    @required String url,
    bool animated = true,
    Map<String, dynamic> params = const {},
  }) =>
      _pageSubject.push(
        url: url,
        animated: animated,
        params: params,
      );

  /// Notify a page with `url` and `index`.
  ///
  static Future<bool> notify({
    @required String name,
    @required String url,
    int index = 0,
    Map<String, dynamic> params = const {},
  }) =>
      _pageSubject.notify(
        name: name,
        url: url,
        index: index,
        params: params,
      );

  /// Pop a page from `ThrioNavigator`.
  ///
  static Future<bool> pop({bool animated = true}) =>
      _pageSubject.pop(animated: animated);

  /// Pop to a page with `url` and `index`.
  ///
  static Future<bool> popTo({
    @required String url,
    int index = 0,
    bool animated = true,
  }) =>
      _pageSubject.popTo(
        url: url,
        index: index,
        animated: animated,
      );

  /// Remove a page with `url` and `index` from `ThrioNavigator`.
  ///
  static Future<bool> remove({
    String url = '',
    int index = 0,
    bool animated = true,
  }) =>
      _pageSubject.remove(
        url: url,
        index: index,
        animated: animated,
      );

  /// Get the index of the last page.
  ///
  static Future<int> lastIndex({String url}) =>
      _pageSubject.lastIndex(url: url);

  /// Get the index of all pages whose url is `url`.
  ///
  static Future<List<int>> allIndex(String index) =>
      _pageSubject.allIndex(index);

  /// Set pop disabled with `url` and `index`.
  ///
  static Future<bool> setPopDisabled({
    @required String url,
    int index = 0,
    bool disabled = true,
  }) =>
      _pageSubject.setPopDisabled(
        url: url,
        index: index,
        disabled: disabled,
      );

  /// Sets up a broadcast stream for receiving page notify events.
  ///
  /// return value is `params`.
  ///
  Stream<Map<String, dynamic>> onPageNotifyStream(
    String name,
    String url, {
    int index,
  }) =>
      _pageObserver.onPageNotifyStream(
        name,
        url,
        index: index,
      );

  /// Register default page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerDefaultPageBuilder(
    ThrioPageBuilder builder,
  ) =>
      _pageBuilders.registry(Navigator.defaultRouteName, builder);

  /// Register an page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerPageBuilder(
    String url,
    ThrioPageBuilder builder,
  ) =>
      _pageBuilders.registry(url, builder);

  /// Register page builders for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerPageBuilders(
    Map<String, ThrioPageBuilder> builders,
  ) =>
      _pageBuilders.registryAll(builders);

  @override
  State<StatefulWidget> createState() => ThrioNavigatorState();
}

class ThrioNavigatorState extends State<ThrioNavigator> {
  List<ThrioPageRoute> get history => widget._observer.pageRoutes;

  /// 还无法实现animated=false
  Future<bool> push(RouteSettings settings, {bool animated = true}) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    final pageBuilder = ThrioNavigator._pageBuilders[settings.url];
    final route = ThrioPageRoute(builder: pageBuilder, settings: settings);
    ThrioLogger().v('push: ${route.settings}');
    navigatorState.push(route);
    return Future.value(true);
  }

  Future<bool> pop({bool animated = true}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    if (history.isEmpty ||
        await history.last.willPop() != RoutePopDisposition.pop) {
      return false;
    }
    ThrioLogger().v('pop: ${history.last.settings}');

    if (animated) {
      navigatorState.pop();
    } else {
      navigatorState.removeRoute(history.last);
    }
    return true;
  }

  Future<bool> popTo(RouteSettings settings, {bool animated = true}) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    final route = history.lastWhere((it) => it.settings.name == settings.name,
        orElse: () => null);
    if (route == null || settings.name == history.last.settings.name) {
      return Future.value(false);
    }
    ThrioLogger().v('popTo: ${route.settings}');
    if (animated) {
      navigatorState.popUntil((it) => it.settings.name == settings.name);
    } else {
      for (var i = history.length - 2; i >= 0; i--) {
        if (history[i].settings.name == settings.name) {
          break;
        }
        navigatorState.removeRoute(history[i]);
      }
      navigatorState.removeRoute(history.last);
    }
    return Future.value(true);
  }

  Future<bool> remove(RouteSettings settings, {bool animated = false}) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    final route = history.lastWhere((it) => it.settings.name == settings.name,
        orElse: () => null);
    if (route == null) {
      return Future.value(false);
    }
    ThrioLogger().v('remove: ${route.settings}');
    if (settings.name == history.last.settings.name) {
      return pop(animated: animated);
    }
    navigatorState.removeRoute(route);
    return Future.value(true);
  }

  Future<bool> setPopDisabled(RouteSettings settings, {bool disabled = true}) {
    final route = history.lastWhere((it) => it.settings.name == settings.name,
        orElse: () => null);
    if (route != null) {
      route.willPopCallback = () async => !disabled;
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      widget.child.observers.add(widget._observer);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (history.isEmpty) {
      ThrioNavigator._channel.invokeMethod<bool>('hotRestart');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
