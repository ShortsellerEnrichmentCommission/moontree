import 'package:flutter/material.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
import 'package:raven_mobile/theme/extensions.dart';

BottomAppBar walletTradingButtons(BuildContext context) => BottomAppBar(
        child: ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
          IconButton(
              onPressed: () {/*to wallet*/},
              icon: Icon(Icons.account_balance_wallet_rounded,
                  color: Theme.of(context).primaryColor)),
          IconButton(
              onPressed: () {/*to trading*/}, icon: Icon(Icons.swap_horiz))
        ]));

GestureDetector settingsButton(BuildContext context, Function setStateFn) =>
    GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, '/settings').then((_) => setStateFn()),
        child: Icon(Icons.more_horiz));

IconButton backIconButton(BuildContext context) =>
    IconButton(icon: RavenIcon.back, onPressed: () => Navigator.pop(context));

ElevatedButton receiveButton(BuildContext context) => ElevatedButton.icon(
    icon: Icon(Icons.south_east),
    label: Text('Receive'),
    onPressed: () => Navigator.pushNamed(context, '/receive'),
    style: RavenButtonStyle.leftSideCurved);

ElevatedButton sendButton(BuildContext context,
        {String symbol = 'RVN', bool disabled = false}) =>
    ElevatedButton.icon(
        icon: Icon(Icons.north_east),
        label: Text('Send'),
        onPressed: disabled
            ? () {}
            : () => Navigator.pushNamed(context, '/send',
                arguments: {'symbol': symbol}),
        style: disabled
            ? RavenButtonStyle.rightSideCurved(context, disabled: true)
            : RavenButtonStyle.rightSideCurved(context));

ElevatedButton getRVNButton(BuildContext context) => ElevatedButton(
      onPressed: () {/* link to coinbase */},
      child: Text('get RVN', style: Theme.of(context).textTheme.headline2),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Theme.of(context).good)),
    );

class RavenButton {
  RavenButton();

  static IconButton back(BuildContext context) => backIconButton(context);
  static GestureDetector settings(BuildContext context, Function setStateFn) =>
      settingsButton(context, setStateFn);
  static BottomAppBar bottomNav(BuildContext context) =>
      walletTradingButtons(context);
  static ElevatedButton receive(BuildContext context) => receiveButton(context);
  static ElevatedButton send(BuildContext context,
          {String symbol = 'RVN', bool disabled = false}) =>
      sendButton(context, symbol: symbol, disabled: disabled);
  static ElevatedButton getRVN(BuildContext context) => getRVNButton(context);
}
