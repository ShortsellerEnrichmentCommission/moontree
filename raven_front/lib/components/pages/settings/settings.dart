import 'package:flutter/material.dart';
import 'package:raven_mobile/pages/settings/about.dart';
import 'package:raven_mobile/pages/settings/currency.dart';
import 'package:raven_mobile/pages/settings/language.dart';
import 'package:raven_mobile/pages/settings/wallet_settings.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/components/buttons.dart';

AppBar header(context) => AppBar(
    backgroundColor: RavenColor().appBar,
    leading: RavenButton().back(context),
    elevation: 2,
    centerTitle: false,
    title: RavenText('Settings').h2);

SettingsList body(context) => SettingsList(
      sections: [
        SettingsSection(tiles: [
          SettingsTile(
              title: 'Wallet',
              subtitle: '<Account Name>',
              leading: Icon(Icons.account_balance_wallet_rounded),
              onPressed: (BuildContext context) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WalletSettings()));
              }),
          SettingsTile(
              title: 'P2P Exchange',
              enabled: false,
              leading: Icon(Icons.swap_horiz),
              onPressed: (BuildContext context) {})
        ]),
        SettingsSection(
          title: 'App',
          tiles: [
            SettingsTile(
                title: 'Currency',
                leading: Icon(Icons.money),
                onPressed: (BuildContext context) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Currency()));
                }),
            SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Language()));
                }),
            SettingsTile(
                title: 'About',
                leading: Icon(Icons.info),
                onPressed: (BuildContext context) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => About()));
                }),
            //SettingsTile.switchTile(
            //  title: 'Use fingerprint',
            //  leading: Icon(Icons.fingerprint),
            //  switchValue: true,
            //  onToggle: (bool value) {},
            //),
          ],
        ),
      ],
    );
