import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/account/transactions.dart';

class HomeSwap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() => Navigator(
      key: components.navigator.keys.navWallet,
      initialRoute: '/swap/assets',
      onGenerateRoute: (RouteSettings settings) {
        /// one liner
        //return PageRouteBuilder(pageBuilder: (_,__,___,) => pages.routesWallet(context)[settings.name], transitionDuration: const Duration(seconds: 0));
        Widget page;
        switch (settings.name) {
          case '/swap/assets':
            page = Transactions();
            break;
          default:
            page = Transactions();
            break;
        }
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => page,
            transitionDuration: const Duration(seconds: 0));
      });
}
