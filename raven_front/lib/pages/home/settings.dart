import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/security/change.dart';
import 'package:raven_front/pages/security/login.dart';
import 'package:raven_front/pages/security/remove.dart';
import 'package:raven_front/pages/security/resume.dart';
import 'package:raven_front/pages/settings/about.dart';
import 'package:raven_front/pages/settings/advanced.dart';
import 'package:raven_front/pages/settings/export.dart';
import 'package:raven_front/pages/settings/import.dart';
import 'package:raven_front/pages/settings/language.dart';
import 'package:raven_front/pages/settings/network.dart';
import 'package:raven_front/pages/settings/preferences.dart';
import 'package:raven_front/pages/settings/security.dart';
import 'package:raven_front/pages/settings/support.dart';
import 'package:raven_front/pages/settings/technical.dart';

class HomeSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() => Navigator(
      key: components.navigator.keys.navWallet,
      initialRoute: '/settings/about',
      onGenerateRoute: (RouteSettings settings) {
        /// one liner
        //return PageRouteBuilder(pageBuilder: (_,__,___,) => pages.routesWallet(context)[settings.name], transitionDuration: const Duration(seconds: 0));
        Widget page;
        switch (settings.name) {
          case '/security/change':
            page = ChangePassword();
            break;
          case '/security/resume':
            page = ChangeResume();
            break;
          case '/security/remove':
            page = RemovePassword();
            break;
          case '/security/login':
            page = Login();
            break;
          case '/settings/about':
            page = About();
            break;
          case '/settings/level':
            page = Advanced();
            break;
          case '/settings/currency':
            page = Language();
            break;
          case '/settings/export':
            page = Export();
            break;
          case '/settings/import':
            page = Import();
            break;
          case '/settings/network':
            page = ElectrumNetwork();
            break;
          case '/settings/preferences':
            page = Preferences();
            break;
          case '/settings/security':
            page = Security();
            break;
          case '/settings/support':
            page = Support();
            break;
          case '/settings/technical':
            page = TechnicalView();
            break;
          default:
            page = About();
            break;
        }
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => page,
            transitionDuration: const Duration(seconds: 0));
      });
}
