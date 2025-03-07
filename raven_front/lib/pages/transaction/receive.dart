import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_front/utils/transformers.dart';
import 'package:raven_front/utils/data.dart';
import 'package:share/share.dart';

class Receive extends StatefulWidget {
  final dynamic data;
  const Receive({this.data}) : super();

  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  Map<String, dynamic> data = {};
  late String address;
  final requestMessage = TextEditingController();
  final requestAmount = TextEditingController();
  final requestLabel = TextEditingController();
  FocusNode requestAmountFocus = FocusNode();
  FocusNode requestLabelFocus = FocusNode();
  FocusNode requestMessageFocus = FocusNode();
  String uri = '';
  String username = '';
  String? errorText;
  List<Security> fetchedNames = <Security>[];

  bool get rawAddress =>
      requestMessage.text == '' &&
      requestAmount.text == '' &&
      requestLabel.text == '';

  void _makeURI() {
    if (rawAddress) {
      uri = address;
    } else {
      var amount = requestAmount.text == ''
          ? ''
          : 'amount=${Uri.encodeComponent(requestAmount.text)}';
      var label = requestLabel.text == ''
          ? ''
          : 'label=${Uri.encodeComponent(requestLabel.text)}';
      var message = requestMessage.text == ''
          ? ''
          //: 'message=${Uri.encodeComponent(requestMessage.text)}';
          : 'message=asset:${Uri.encodeComponent(requestMessage.text)}';
      var to = username == '' ? '' : 'to=${Uri.encodeComponent(username)}';
      var tail = [amount, label, message, to].join('&').replaceAll('&&', '&');
      tail = '?' +
          (tail.endsWith('&') ? tail.substring(0, tail.length - 1) : tail);
      tail = tail.length == 1 ? '' : tail;
      uri = 'raven:$address$tail';
    }
    setState(() => {});
  }

  @override
  void initState() {
    super.initState();
    requestMessage.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    requestMessage.dispose();
    requestAmount.dispose();
    requestLabel.dispose();
    super.dispose();
  }

  void _printLatestValue() async {
    fetchedNames = requestMessage.text.length <= 32
        ? (await services.client.api.getAssetNames(requestMessage.text))
            .toList()
            .map((e) =>
                Security(symbol: e, securityType: SecurityType.RavenAsset))
            .toList()
        : [];
  }

  @override
  Widget build(BuildContext context) {
    username =
        res.settings.primaryIndex.getOne(SettingName.User_Name)?.value ?? '';
    data = populateData(context, data);
    requestMessage.text = requestMessage.text == ''
        ? data['symbol'] != null && data['symbol'] != ''
            ? data['symbol']
            : ''
        : requestMessage.text;
    address = services.wallet.getEmptyWallet(Current.wallet).address!;
    uri = uri == '' ? address : uri;
    //requestMessage.selection =
    //    TextSelection.collapsed(offset: requestMessage.text.length);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _makeURI();
      },
      child: body(),
    );
  }

  Widget body() => Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 40),
      child: CustomScrollView(
        // solves scrolling while keyboard
        shrinkWrap: true,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// if this is a RVNt account we could show that here...
                //SizedBox(height: 15.0),
                //Text(
                //    // rvn is default but if balance is 0 then take the largest asset balance and also display name here.
                //    'RVN',
                //    textAlign: TextAlign.center),
                SizedBox(height: 20.0),
                GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(
                          new ClipboardData(text: rawAddress ? address : uri));
                      streams.app.snack.add(Snack(
                          message: 'Copied to Clipboard', atBottom: true));
                      // not formatted the same...
                      //ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                      //  content: new Text("Copied to Clipboard"),
                      //));
                    },
                    child: Center(

                        /// long hold copy and maybe on tap?
                        child: QrImage(
                            backgroundColor: Colors.white,
                            data: rawAddress ? address : uri,
                            version: QrVersions.auto,
                            foregroundColor: AppColors.primary,
                            embeddedImage:
                                Image.asset('assets/logo/moontree_logo.png')
                                    .image,
                            size: 300.0))),

                /// At this time we're not going to show them any information but the
                /// QR Code, not even the address, if they copy by long pressing the
                /// QR Code, they can get the address or this information if its
                /// constructed.
                //SizedBox(height: 10.0),
                //Center(
                //    child: Column(
                //        crossAxisAlignment: CrossAxisAlignment.center,
                //        children: [
                //      /// does not belong on UI but I still want an indication that what is on QR code is not raw address...
                //      Visibility(
                //          visible: !rawAddress,
                //          child: Text(
                //            'raven:',
                //            style: Theme.of(context).textTheme.caption,
                //          )),
                //      SelectableText(
                //        address,
                //        cursorColor: Colors.grey[850],
                //        showCursor: true,
                //        toolbarOptions: ToolbarOptions(
                //            copy: true, selectAll: true, cut: false, paste: false),
                //      ),
                //      Visibility(
                //          visible: !rawAddress && username != '',
                //          child: Text(
                //            'to: $username',
                //            style: Theme.of(context).textTheme.caption,
                //          )),
                //      Visibility(
                //          visible: !rawAddress && requestMessage.text != '',
                //          child: Text(
                //            'asset: ${requestMessage.text}',
                //            style: Theme.of(context).textTheme.caption,
                //          )),
                //      Visibility(
                //          visible: !rawAddress && requestAmount.text != '',
                //          child: Text(
                //            'amount: ${requestAmount.text}',
                //            style: Theme.of(context).textTheme.caption,
                //          )),
                //      Visibility(
                //          visible: !rawAddress && requestLabel.text != '',
                //          child: Text(
                //            'note: ${requestLabel.text}',
                //            style: Theme.of(context).textTheme.caption,
                //          )),
                //    ])),
                //SizedBox(height: 20.0),

                /// this autocomplete will actually populate after 3 characters
                /// have been entered by asking electrum what assets start
                /// with those 3 characters. However, this is old functionality
                /// and will have to be modified anyway (because of our special
                /// use of subsassets namespaces etc), Furthermore, it seems
                /// an Autocomplete widget doesn't accept an InputDecoration,
                /// making formatting it to look the same as the others difficult
                /// thus, we're commenting it out now, in order to extract it's
                /// functionality later and currently replacing it with a simple
                /// text field.
                //Column(
                //    crossAxisAlignment: CrossAxisAlignment.start,
                //    mainAxisAlignment: MainAxisAlignment.start,
                //    children: <Widget>[
                //      SizedBox(height: 15),
                //      Text(
                //        'Requested Asset:',
                //        style: TextStyle(color: Theme.of(context).hintColor),
                //      ),
                //      Autocomplete<Security>(
                //        displayStringForOption: _displayStringForOption,
                //        initialValue: TextEditingValue(text: requestMessage.text),
                //        optionsBuilder: (TextEditingValue textEditingValue) {
                //          requestMessage.text = textEditingValue.text;
                //          _makeURI();
                //          if (requestMessage.text == '') {
                //            return const Iterable<Security>.empty();
                //          }
                //          if (requestMessage.text == 't') {
                //            return [
                //              Security(
                //                  symbol: 'testing',
                //                  securityType: SecurityType.Fiat)
                //            ];
                //          }
                //          if (requestMessage.text.length >= 3) {
                //            return fetchedNames;
                //          }
                //          //(await services.client.api.getAllAssetNames(textEditingValue.text)).map((String s) => Security(
                //          //        symbol: s,
                //          //        securityType: SecurityType.RavenAsset));
                //          return securities.data
                //              .where((Security option) => option.symbol
                //                  .contains(requestMessage.text.toUpperCase()))
                //              .toList()
                //              .reversed;
                //        },
                //        optionsMaxHeight: 100,
                //        onSelected: (Security selection) async {
                //          requestMessage.text = selection.symbol;
                //          _makeURI();
                //          FocusScope.of(context).requestFocus(requestAmountFocus);
                //        },
                //      ),
                //      SizedBox(height: 15.0),
                //    ]),
                SizedBox(height: 16),
                TextField(
                    focusNode: requestMessageFocus,
                    controller: requestMessage,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      MainAssetNameTextFormatter(),
                    ],
                    //maxLength: 32,
                    //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: components.styles.decorations.textFeild(context,
                        labelText: 'Requested Asset',
                        hintText: 'Ravencoin',
                        errorText: errorText),
                    onChanged: (value) {
                      // /requestMessage.text = cleanLabel(requestMessage.text);
                      // /_makeURI();
                      var oldErrorText = errorText;
                      errorText = value.length > 32 ? 'too long' : null;
                      if (oldErrorText != errorText) {
                        setState(() {});
                      }
                    },
                    onEditingComplete: () {
                      requestMessage.text = cleanLabel(requestMessage.text);
                      _makeURI();
                      FocusScope.of(context).requestFocus(requestAmountFocus);
                    }),
                SizedBox(height: 16),
                TextField(
                    focusNode: requestAmountFocus,
                    controller: requestAmount,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: components.styles.decorations.textFeild(context,
                        labelText: 'Amount', hintText: 'Quantity'),
                    onChanged: (value) {
                      //requestAmount.text = cleanDecAmount(requestAmount.text);
                      //_makeURI();
                    },
                    onEditingComplete: () {
                      requestAmount.text = cleanDecAmount(
                        requestAmount.text,
                        zeroToBlank: true,
                      );
                      _makeURI();
                      FocusScope.of(context).requestFocus(requestLabelFocus);
                    }),
                SizedBox(height: 16),
                TextField(
                  focusNode: requestLabelFocus,
                  autocorrect: false,
                  controller: requestLabel,
                  decoration: components.styles.decorations.textFeild(context,
                      labelText: 'Note', hintText: 'for groceries'),
                  onChanged: (value) {
                    //requestLabel.text = cleanLabel(requestLabel.text);
                    //_makeURI();
                  },
                  onEditingComplete: () {
                    requestLabel.text = cleanLabel(requestLabel.text);
                    _makeURI();
                    FocusScope.of(context).unfocus();
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Row(children: [shareButton]),
          ),
        ],
      ));

  /// see Autocomplete above
  //static String _displayStringForOption(Security option) => option.symbol;

  Widget get shareButton => components.buttons.actionButton(
        context,
        label: 'Share',
        onPressed: () => Share.share(uri),
      );
}
