import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/extensions/string.dart';

class RouteStack extends NavigatorObserver {
  NavKeys keys = NavKeys();

  List<Route<dynamic>> routeStack = [];
  List<Route<dynamic>> routeStackApp = [];
  List<Route<dynamic>> routeStackWallet = [];
  List<Route<dynamic>> routeStackManage = [];
  List<Route<dynamic>> routeStackSwap = [];
  BuildContext? routeContext;
  BuildContext? scaffoldContext;
  TabController? tabController;

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.add(route);
    // also push to the correct routeStack
    routeContext = route.navigator?.context;
    streams.app.page.add(conformName(route.settings.name));
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.removeLast();
    routeContext = routeStack.last.navigator?.context;
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    routeStack.removeLast();
    routeContext = routeStack.last.navigator?.context;
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    routeStack.removeLast();
    if (newRoute != null) {
      routeStack.add(newRoute);
    }
    routeContext = routeStack.last.navigator?.context;
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  String conformName(String? name) =>
      handleHome(name?.split('/').last.toTitleCase() ?? streams.app.page.value);

  String handleHome(String name) => name == 'Home' ? 'Wallet' : name;
}

class NavKeys {
  final GlobalKey<NavigatorState> navApp = GlobalKey();
  final GlobalKey<NavigatorState> navSettings = GlobalKey();
  final GlobalKey<NavigatorState> navWallet = GlobalKey();
  final GlobalKey<NavigatorState> navManage = GlobalKey();
  final GlobalKey<NavigatorState> navSwap = GlobalKey();
}
