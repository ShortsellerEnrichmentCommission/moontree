import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/account/transactions.dart';
import 'package:raven_front/pages/misc/scan.dart';
import 'package:raven_front/pages/pages.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/pages/transaction/receive.dart';
import 'package:raven_front/pages/transaction/send.dart';
import 'package:raven_front/pages/transaction/transaction.dart';
import 'package:raven_front/pages/wallet/wallet.dart';
import 'package:raven_front/widgets/front/loader.dart';

class HomeWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() => Navigator(
      key: components.navigator.keys.navWallet,
      initialRoute: '/transactions',
      onGenerateRoute: (RouteSettings settings) {
        /// one liner
        //return PageRouteBuilder(pageBuilder: (_,__,___,) => pages.routesWallet(context)[settings.name], transitionDuration: const Duration(seconds: 0));
        Widget page;
        switch (settings.name) {
          case '/transactions':
            page = Transactions();
            break;
          case '/wallet':
            page = WalletView();
            break;
          case '/loader':
            page = Loader();
            break;
          case '/scan':
            page = ScanQR();
            break;
          case '/transaction/transaction':
            page = TransactionPage();
            break;
          case '/transaction/receive':
            page = Receive();
            break;
          case '/transaction/send':
            page = Send();
            break;
          case '/transaction/checkout':
            page = Checkout();
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
