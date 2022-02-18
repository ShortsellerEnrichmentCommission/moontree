import 'package:flutter/cupertino.dart';
import 'package:raven_front/pages/account/home.dart';
import 'package:raven_front/pages/account/transactions.dart';
import 'package:raven_front/pages/manage/assets.dart';
import 'package:raven_front/pages/create/nft.dart';
import 'package:raven_front/pages/create/main.dart';
import 'package:raven_front/pages/create/qualifier.dart';
import 'package:raven_front/pages/create/channel.dart';
import 'package:raven_front/pages/create/restricted.dart';
import 'package:raven_front/pages/misc/loading.dart';
import 'package:raven_front/pages/misc/scan.dart';
import 'package:raven_front/pages/security/login.dart';
import 'package:raven_front/pages/security/remove.dart';
import 'package:raven_front/pages/security/resume.dart';
import 'package:raven_front/pages/security/change.dart';
import 'package:raven_front/pages/settings/about.dart';
import 'package:raven_front/pages/settings/currency.dart';
import 'package:raven_front/pages/settings/export.dart';
import 'package:raven_front/pages/settings/import.dart';
import 'package:raven_front/pages/settings/language.dart';
import 'package:raven_front/pages/settings/network.dart';
import 'package:raven_front/pages/settings/advanced.dart';
import 'package:raven_front/pages/settings/preferences.dart';
import 'package:raven_front/pages/settings/security.dart';
import 'package:raven_front/pages/settings/support.dart';
import 'package:raven_front/pages/settings/technical.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/pages/transaction/receive.dart';
import 'package:raven_front/pages/transaction/send.dart';
import 'package:raven_front/pages/transaction/transaction.dart';
import 'package:raven_front/pages/wallet/wallet.dart';
import 'package:raven_front/widgets/front/loader.dart';
import 'package:raven_front/pages/home/wallet.dart';
import 'package:raven_front/pages/home/manage.dart';
import 'package:raven_front/pages/home/swap.dart';
import 'package:raven_front/pages/home/settings.dart';

class pages {
  static Loading loading = Loading();
  static ChangePassword changePassword = ChangePassword();
  static ChangeResume changeResume = ChangeResume();
  static Login login = Login();
  static Home home = Home();
  static Asset asset = Asset();
  static Transactions transactions = Transactions();
  static CreateNFTAsset createNFTAsset = CreateNFTAsset();
  static CreateMainAsset createMainAsset = CreateMainAsset();
  static CreateQualifierAsset createQualifierAsset = CreateQualifierAsset();
  static CreateChannelAsset createChannelAsset = CreateChannelAsset();
  static CreateRestrictedAsset createRestrictedAsset = CreateRestrictedAsset();
  static Checkout checkout = Checkout();
  static TransactionPage transaction = TransactionPage();
  static Receive receive = Receive();
  static Send send = Send();
  static About about = About();
  static Advanced advanced = Advanced();
  static Export export = Export();
  static Import import = Import();
  static Language language = Language();
  static Loader loader = Loader();
  static ElectrumNetwork electrumNetwork = ElectrumNetwork();
  static Preferences preferences = Preferences();
  static RemovePassword removePassword = RemovePassword();
  static Currency currency = Currency();
  static ScanQR scan = ScanQR();
  static Support support = Support();
  static Security security = Security();
  static TechnicalView technicalView = TechnicalView();
  static WalletView walletView = WalletView();

  static HomeWallet homeWallet = HomeWallet();
  static HomeManage homeManage = HomeManage();
  static HomeSwap homeSwap = HomeSwap();
  static HomeSettings homeSettings = HomeSettings();

  static Map<String, Widget Function(BuildContext)> routesApp(
    BuildContext context,
  ) =>
      {
        '/': (BuildContext context) => loading,
        '/home/wallet': (BuildContext context) => homeWallet,
        '/home/manage': (BuildContext context) => homeManage,
        '/home/swap': (BuildContext context) => homeSwap,
        '/home/settings': (BuildContext context) => homeSettings,
      };

  static Map<String, Widget Function(BuildContext)> routesSettings(
    BuildContext context,
  ) =>
      {
        '/security/change': (BuildContext context) => changePassword,
        '/security/resume': (BuildContext context) => changeResume,
        '/security/remove': (BuildContext context) => removePassword,
        '/security/login': (BuildContext context) => login,
        '/settings/about': (BuildContext context) => about,
        '/settings/level': (BuildContext context) => advanced,
        '/settings/currency': (BuildContext context) => language,
        '/settings/export': (BuildContext context) => export,
        '/settings/import': (BuildContext context) => import,
        '/settings/network': (BuildContext context) => electrumNetwork,
        '/settings/preferences': (BuildContext context) => preferences,
        '/settings/security': (BuildContext context) => security,
        '/settings/support': (BuildContext context) => support,
        '/settings/technical': (BuildContext context) => technicalView,
      };
  static Map<String, Widget Function(BuildContext)> routesWallet(
    BuildContext context,
  ) =>
      {
        '/transactions': (BuildContext context) => transactions,
        '/wallet': (BuildContext context) => walletView,
        '/loader': (BuildContext context) => loader,
        '/scan': (BuildContext context) => scan,
        '/transaction/transaction': (BuildContext context) => transaction,
        '/transaction/receive': (BuildContext context) => receive,
        '/transaction/send': (BuildContext context) => send,
        '/transaction/checkout': (BuildContext context) => checkout,
      };
  static Map<String, Widget Function(BuildContext)> routesManage(
    BuildContext context,
  ) =>
      {
        '/manage/asset': (BuildContext context) => asset,
        '/create/nft': (BuildContext context) => createNFTAsset,
        '/create/main': (BuildContext context) => createMainAsset,
        '/create/qualifier': (BuildContext context) => createQualifierAsset,
        '/create/channel': (BuildContext context) => createChannelAsset,
        '/create/restricted': (BuildContext context) => createRestrictedAsset,
      };
  static Map<String, Widget Function(BuildContext)> routesSwap(
    BuildContext context,
  ) =>
      {
        //'/swap/assets': (BuildContext context) => technicalView,
      };

  static Map<String, Widget Function(BuildContext)> routesAll(
    BuildContext context,
  ) =>
      routesApp(context)
        ..addAll(routesWallet(context))
        ..addAll(routesManage(context))
        ..addAll(routesSwap(context))
        ..addAll(routesSettings(context));
}
