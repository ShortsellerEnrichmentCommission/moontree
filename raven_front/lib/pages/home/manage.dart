import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/account/transactions.dart';
import 'package:raven_front/pages/create/channel.dart';
import 'package:raven_front/pages/create/main.dart';
import 'package:raven_front/pages/create/nft.dart';
import 'package:raven_front/pages/create/qualifier.dart';
import 'package:raven_front/pages/create/restricted.dart';
import 'package:raven_front/pages/manage/assets.dart';

class HomeManage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() => Navigator(
      key: components.navigator.keys.navWallet,
      initialRoute: '/manage/asset',
      onGenerateRoute: (RouteSettings settings) {
        /// one liner
        //return PageRouteBuilder(pageBuilder: (_,__,___,) => pages.routesWallet(context)[settings.name], transitionDuration: const Duration(seconds: 0));
        Widget page;
        switch (settings.name) {
          case '/manage/asset':
            page = Asset();
            break;
          case '/create/nft':
            page = CreateNFTAsset();
            break;
          case '/create/main':
            page = CreateMainAsset();
            break;
          case '/create/qualifier':
            page = CreateQualifierAsset();
            break;
          case '/create/channel':
            page = CreateChannelAsset();
            break;
          case '/create/restricted':
            page = CreateRestrictedAsset();
            break;
          default:
            page = Asset();
            break;
        }
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => page,
            transitionDuration: const Duration(seconds: 0));
      });
}
