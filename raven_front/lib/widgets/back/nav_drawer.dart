import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:raven_back/extensions/list.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

//testing
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_electrum/methods/transaction/get.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({Key? key}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  List listeners = [];
  String? chosen = '/settings';

  @override
  void initState() {
    super.initState();
    //listeners.add(streams.app.page.listen((value) {
    //  if (value != pageTitle) {
    //    setState(() {
    //      pageTitle = value;
    //    });
    //  }
    //}));
    listeners.add(streams.app.setting.listen((String? value) {
      if (value != chosen) {
        setState(() {
          chosen = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Widget destination({
    required String name,
    required String link,
    IconData? icon,
    Image? image,
    bool arrow = false,
    Map<String, dynamic>? arguments,
    Function? execute,
  }) =>
      ListTile(
        onTap: () {
          if (execute != null) {
            execute();
          }
          if (!arrow) {
            Backdrop.of(components.navigator.routeContext!).fling();
            Navigator.of(components.navigator.routeContext!).pushNamed(
              link,
              arguments: arguments,
            );
            streams.app.setting.add(null);
          } else {
            streams.app.setting.add(link);
          }
        },
        leading: icon != null ? Icon(icon, color: Colors.white) : image!,
        title: Text(name, style: Theme.of(context).textTheme.headline5),
        trailing: arrow ? Icon(Icons.chevron_right, color: Colors.white) : null,
      );

  @override
  Widget build(BuildContext context) {
    var options = {
      '/settings/import_export': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        children: [
          destination(
              icon: MdiIcons.fileImport,
              name: 'Import',
              link: '/settings/import'),
          destination(
              icon: MdiIcons.fileExport,
              name: 'Export',
              link: '/settings/export'),
        ],
      ),
      '/settings/settings': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        children: [
          destination(
              icon: Icons.lock_rounded,
              name: 'Security',
              link: '/settings/security'),
          destination(
              icon: MdiIcons.accountCog,
              name: 'User Level',
              link: '/settings/level'),
          destination(
              icon: MdiIcons.network,
              name: 'Network',
              link: '/settings/network',
              execute: () {
                streams.app.verify.add(false);
              }),
        ],
      ),
      '/settings': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        children: [
          destination(
            icon: MdiIcons.shieldKey,
            name: 'Import / Export',
            link: '/settings/import_export',
            arrow: true,
          ),
          destination(
            icon: Icons.settings,
            name: 'Settings',
            link: '/settings/settings',
            arrow: true,
          ),
          destination(
            icon: Icons.feedback,
            name: 'Feedback',
            link: '/settings/feedback',
          ),
          destination(
            icon: Icons.help,
            name: 'Support',
            link: '/settings/support',
          ),
          destination(
            icon: Icons.info_rounded,
            name: 'About',
            link: '/settings/about',
          ),
          /*
          SettingsTile(
              title: 'Clear Database',
              titleTextStyle: Theme.of(context).drawerDestination,
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) {
                ravenDatabase.deleteDatabase();
              }),
          destination(
            icon: Icons.info_rounded,
            name: 'Accounts',
            link: '/settings/technical',
          ),
          SettingsTile(
              title: 'test',
              titleTextStyle: Theme.of(context).drawerDestination,
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) async {
                print(res.assets.data
                    .where((Asset asset) => asset.symbol.contains('MOONTREE2'))
                    .map((e) => e.symbol));
                var client = streams.client.client.value!;
                var tx = await client.getTransaction(
                    '9eaa220b15d2802d8ec04075f22136d0783a2064254b3c9cc5d762882f02bf15');
                print(tx.vout[4]);
              }),
            */
        ],
      )
    };
    return GestureDetector(
        onTap: ScaffoldMessenger.of(context).hideCurrentSnackBar,
        child: Container(
            height: MediaQuery.of(context).size.height - 118 - 10,

            /// using a listview makes it variable so you don't have to define height
            //height: 300,
            //child: Column(
            //  crossAxisAlignment: CrossAxisAlignment.start,
            ///

            child: Column(
              children: [
                if (res.wallets.length > 1)
                  Divider(indent: 0, color: AppColors.white12),
                (options[chosen] ?? options['/settings'])!
              ],
            )));
  }
}
