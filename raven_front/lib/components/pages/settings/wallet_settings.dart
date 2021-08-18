import 'package:flutter/material.dart';
import 'package:raven_mobile/pages/settings/export.dart';
import 'package:raven_mobile/pages/settings/import.dart';
import 'package:raven_mobile/pages/technical.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/components/buttons.dart';

AppBar header(context) => AppBar(
    backgroundColor: RavenColor().appBar,
    leading: RavenButton().back(context),
    elevation: 2,
    centerTitle: false,
    title: RavenText('Wallet Settings').h2);

SettingsList body(context) => SettingsList(sections: [
      SettingsSection(tiles: [
        SettingsTile(
            title: 'Import Wallet',
            leading: Icon(Icons.account_balance_wallet_rounded),
            onPressed: (BuildContext context) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Import()));
            }),
        SettingsTile(
            title: 'Export/Backup Wallet',
            leading: Icon(Icons.swap_horiz),
            onPressed: (BuildContext context) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Export()));
            }),
        SettingsTile(
            title: 'Technical View',
            leading: Icon(Icons.swap_horiz),
            onPressed: (BuildContext context) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TechnicalView()));
            }),
        SettingsTile(
            title: 'Sign Message',
            enabled: false,
            leading: Icon(Icons.swap_horiz),
            onPressed: (BuildContext context) {
              //Navigator.push(
              //  context,
              //  MaterialPageRoute(builder: (context) => ...()),
              //);
            })
      ])
    ]);
