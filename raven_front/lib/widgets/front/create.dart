import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_back/utils/utilities.dart';
import 'package:raven_back/streams/create.dart';
import 'package:raven_front/utils/transformers.dart';
import 'package:raven_front/widgets/widgets.dart';

enum FormPresets {
  main,
  sub,
  restricted,
  qualifier,
  qualifierSub,
  NFT,
  channel,
}

class CreateAsset extends StatefulWidget {
  static const int ipfsLength = 89;
  static const int quantityMax = 21000000;
  final FormPresets preset;
  final bool isSub;

  CreateAsset({
    required this.preset,
    this.isSub = false,
  }) : super();

  @override
  _CreateAssetState createState() => _CreateAssetState();
}

class _CreateAssetState extends State<CreateAsset> {
  List<StreamSubscription> listeners = [];
  GenericCreateForm? createForm;
  TextEditingController parentController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController decimalController = TextEditingController();
  TextEditingController verifierController = TextEditingController();
  bool reissueValue = true;
  FocusNode parentFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode ipfsFocus = FocusNode();
  FocusNode nextFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();
  FocusNode decimalFocus = FocusNode();
  FocusNode verifierFocus = FocusNode();
  bool nameValidated = false;
  bool ipfsValidated = false;
  bool quantityValidated = false;
  bool decimalValidated = false;
  String? nameValidationErr;
  String? parentValidationErr;
  bool verifierValidated = false;
  String? verifierValidationErr;
  int remainingNameLength = 31;
  int remainingVerifierLength = 89;
  Map<FormPresets, String> presetToTitle = {
    FormPresets.main: 'Asset Name',
    FormPresets.restricted: 'Restricted Asset Name',
    FormPresets.qualifier: 'Qualifier Name',
    FormPresets.NFT: 'NFT Name',
    FormPresets.channel: 'Message Channel Name',
  };

  @override
  void initState() {
    super.initState();
    listeners.add(streams.create.form.listen((GenericCreateForm? value) {
      if (createForm != value) {
        setState(() {
          createForm = value;
          parentController.text = value?.parent ?? parentController.text;
          nameController.text = value?.name ?? nameController.text;
          ipfsController.text = value?.ipfs ?? ipfsController.text;
          quantityController.text =
              value?.quantity?.toString() ?? quantityController.text;
          decimalController.text = value?.decimal ?? decimalController.text;
          reissueValue = value?.reissuable ?? reissueValue;
          verifierController.text = value?.verifier ?? verifierController.text;
        });
      }
    }));
  }

  @override
  void dispose() {
    parentFocus.dispose();
    nameController.dispose();
    ipfsController.dispose();
    quantityController.dispose();
    decimalController.dispose();
    nameFocus.dispose();
    ipfsFocus.dispose();
    nextFocus.dispose();
    quantityFocus.dispose();
    decimalFocus.dispose();
    verifierController.dispose();
    verifierFocus.dispose();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    remainingNameLength =
        // max asset length
        31 -
            // parent text and implied '/'
            (isSub ? parentController.text.length + 1 : 0) -
            // everything else has a special character denoting its type
            (isMain ? 0 : 1);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: body(),
    );
  }

  bool get isSub => widget.isSub;
  // parentController.text.length > 0;
  // above is shorthand, full logic:
  //    !isRestricted &&
  //    ((isNFT || isChannel) ||
  //        (isMain && widget.parent != null) ||
  //        (isQualifier && widget.parent != null));

  bool get isMain => widget.preset == FormPresets.main;
  bool get isNFT => widget.preset == FormPresets.NFT;
  bool get isChannel => widget.preset == FormPresets.channel;
  bool get isQualifier => widget.preset == FormPresets.qualifier;
  bool get isRestricted => widget.preset == FormPresets.restricted;

  bool get needsParent => isSub && (isMain || isNFT || isChannel);
  bool get needsQualifierParent => isSub && isQualifier;
  bool get needsNFTParent => isNFT || isChannel;
  bool get needsQuantity => isMain || isRestricted || isQualifier;
  bool get needsDecimal => isMain || isRestricted;
  bool get needsVerifier => isRestricted;
  bool get needsReissue => isMain || isRestricted;

  Widget body() => CustomScrollView(
          // solves scrolling while keyboard
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (needsParent || needsQualifierParent)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                            child: parentFeild,
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: nameField,
                        ),
                        if (needsQuantity)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: quantityField,
                          ),
                        if (needsDecimal)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: decimalField,
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: ipfsField,
                        ),
                        if (needsVerifier)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: verifierField,
                          ),
                        if (needsReissue)
                          Padding(
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                              child: reissueRow),
                      ]),
                ])),
            SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                    padding: EdgeInsets.only(bottom: 40, left: 16, right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [submitButton])
                      ],
                    )))
          ]);

  Widget get parentFeild => TextField(
        focusNode: parentFocus,
        controller: parentController,
        readOnly: true,
        decoration: components.styles.decorations.textFeild(context,
            labelText: 'Parent ' + (isQualifier ? 'Qualifier' : 'Asset'),
            hintText: 'Parent ' + (isQualifier ? 'Qualifier' : 'Asset'),
            errorText: parentValidationErr,
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.expand_more_rounded,
                      color: Color(0xDE000000))),
              onPressed: () => isQualifier
                  ? _produceQualifierParentModal()
                  : _produceParentModal(), // main subs, nft, channel
            )),
        onTap: () => isQualifier
            ? _produceQualifierParentModal()
            : _produceParentModal(), // main subs, nft, channel
        onChanged: (String? newValue) {
          FocusScope.of(context).requestFocus(ipfsFocus);
          setState(() {});
        },
      );

  Widget get nameField => TextField(
      focusNode: nameFocus,
      autocorrect: false,
      controller: nameController,
      textInputAction: TextInputAction.done,
      keyboardType: isRestricted ? TextInputType.none : null,
      inputFormatters: [MainAssetNameTextFormatter()],
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: (isSub && !isNFT && !isChannel ? 'Sub ' : '') +
            presetToTitle[widget.preset]!,
        hintText: 'MOONTREE_WALLET.COM',
        errorText: isChannel || isRestricted
            ? null
            : nameController.text.length > 2 &&
                    !nameValidation(nameController.text)
                ? nameValidationErr
                : null,
      ),
      onTap: isRestricted ? _produceAdminAssetModal : null,
      onChanged:
          isRestricted ? null : (String value) => validateName(name: value),
      onEditingComplete: isQualifier || isRestricted
          ? () => FocusScope.of(context).requestFocus(quantityFocus)
          : isNFT || isChannel
              ? () => FocusScope.of(context).requestFocus(ipfsFocus)
              : () {
                  formatName();
                  validateName();
                  FocusScope.of(context).requestFocus(quantityFocus);
                });

  Widget get quantityField => TextField(
        focusNode: quantityFocus,
        controller: quantityController,
//      keyboardType: TextInputType.number,
        keyboardType:
            TextInputType.numberWithOptions(decimal: false, signed: false),
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          // selection messed up: don't do it on edit, do it on complete,
          //CommaIntValueTextFormatter()
        ],
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Quantity',
          hintText: '21,000,000',
          errorText: quantityController.text != '' &&
                  !quantityValidation(quantityController.text.toInt())
              ? 'must ${quantityController.text.toInt().toCommaString()} be between 1 and 21,000,000'
              : null,
        ),
        onChanged: (String value) => validateQuantity(quantity: value.toInt()),
        onEditingComplete: () {
          formatQuantity();
          FocusScope.of(context)
              .requestFocus(isQualifier ? ipfsFocus : decimalFocus);
        },
      );

  Widget get decimalField => TextField(
        focusNode: decimalFocus,
        controller: decimalController,
        readOnly: true,
        decoration: components.styles.decorations.textFeild(context,
            labelText: 'Decimals',
            hintText: 'Decimals',
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.expand_more_rounded,
                      color: Color(0xDE000000))),
              onPressed: () => _produceDecimalModal(),
            )),
        onTap: () => _produceDecimalModal(),
        onChanged: (String? newValue) {
          FocusScope.of(context).requestFocus(ipfsFocus);
          setState(() {});
        },
      );

  Widget get verifierField => TextField(
      focusNode: verifierFocus,
      autocorrect: false,
      controller: verifierController,
      textInputAction: TextInputAction.done,
      inputFormatters: [VerifierStringTextFormatter()],
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'Verifier String',
        hintText: '((#KYC & #ACCREDITED) | #EXEMPT) & !#IRS',
        errorText: verifierController.text.length > 2 &&
                !verifierValidation(verifierController.text)
            ? verifierValidationErr
            : null,
      ),
      onChanged: (String value) => validateVerifier(verifier: value),
      onEditingComplete: () {
        validateVerifier();
        FocusScope.of(context).requestFocus(ipfsFocus);
      });

  Widget get ipfsField => TextField(
        focusNode: ipfsFocus,
        autocorrect: false,
        controller: ipfsController,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'IPFS/Txid',
          hintText: 'QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr',
          //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
          errorText: !ipfsValidation(ipfsController.text)
              ? '${CreateAsset.ipfsLength - ipfsController.text.length}'
              : null,
        ),
        onChanged: (String value) => validateIPFS(ipfs: value),
        onEditingComplete: () => FocusScope.of(context).requestFocus(nextFocus),
      );

  Widget get reissueRow => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: Text('Reissuable asset can increase in quantity and '
                      'decimal in the future.\n\nNon-reissuable '
                      'assets cannot be modified in anyway.'),
                ),
              ),
              icon: const Icon(
                Icons.help_rounded,
                color: Colors.black,
              ),
            ),
            Text('Reissuable', style: Theme.of(context).textTheme.bodyText1),
          ]),
          Switch(
            value: reissueValue,
            activeColor: Theme.of(context).backgroundColor,
            onChanged: (bool value) {
              setState(() {
                reissueValue = value;
              });
            },
          )
        ],
      );

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: nextFocus,
        enabled: enabled,
        onPressed: submit,
      );

  bool nameValidation(String name) {
    if (!(name.length > 2 && name.length <= remainingNameLength)) {
      nameValidationErr = '${remainingNameLength - nameController.text.length}';
      return false;
    } else if (name.endsWith('.') || name.endsWith('_')) {
      nameValidationErr = 'cannot end with special character';
      return false;
    }
    nameValidationErr = null;
    return true;
  }

  bool parentValidation(String name) {
    if (isSub) {
      if (!(name.length > 2)) {
        //parentValidationErr =
        //    '${isNFT ? 'NFT' : isChannel ? 'Message Channel' : isQualifier ? 'Sub Qualifier' : 'Sub'} Assets must have a parent';
        return false;
      }
    }
    //parentValidationErr = null;
    return true;
  }

  void validateName({String? name}) {
    name = name ?? nameController.text;
    var oldValidation = nameValidated;
    nameValidated = nameValidation(name);
    if (oldValidation != nameValidated || !nameValidated) {
      setState(() => {});
    }
  }

  bool verifierValidation(String verifier) {
    if (verifier.length > remainingVerifierLength) {
      verifierValidationErr =
          '${remainingVerifierLength - verifierController.text.length}';
      return false;
      //} else if (verifier.endsWith('.') || verifier.endsWith('_')) {
      //  verifierValidationErr = 'allowed characters: A-Z, 0-9, (._#&|!)';
      //  ret = false;
    } else if ('('.allMatches(verifier).length !=
        ')'.allMatches(verifier).length) {
      verifierValidationErr =
          '${'('.allMatches(verifier).length} open parenthesis, '
          '${')'.allMatches(verifier).length} closed parenthesis';
      return false;
    }
    verifierValidationErr = null;
    return true;
  }

  void validateVerifier({String? verifier}) {
    verifier = verifier ?? verifierController.text;
    var oldValidation = verifierValidated;
    verifierValidated = verifierValidation(verifier);
    if (oldValidation != verifierValidated || !verifierValidated) {
      setState(() => {});
    }
  }

  bool ipfsValidation(String ipfs) => ipfs.length <= CreateAsset.ipfsLength;

  void validateIPFS({String? ipfs}) {
    ipfs = ipfs ?? ipfsController.text;
    var oldValidation = ipfsValidated;
    ipfsValidated = ipfsValidation(ipfs);
    if (oldValidation != ipfsValidated || !ipfsValidated) {
      setState(() => {});
    }
  }

  bool quantityValidation(int quantity) =>
      quantityController.text != '' &&
      quantity <= CreateAsset.quantityMax &&
      quantity > 0;

  void validateQuantity({int? quantity}) {
    quantity = quantity ?? quantityController.text.toInt();
    var oldValidation = quantityValidated;
    quantityValidated = quantityValidation(quantity);
    if (oldValidation != quantityValidated || !quantityValidated) {
      setState(() => {});
    }
  }

  bool decimalValidation(int decimal) =>
      decimalController.text != '' && decimal >= 0 && decimal <= 8;

  void validateDecimal({int? decimal}) {
    decimal = decimal ?? decimalController.text.toInt();
    var oldValidation = decimalValidated;
    decimalValidated = decimalValidation(decimal);
    if (oldValidation != decimalValidated || !decimalValidated) {
      setState(() => {});
    }
  }

  bool get enabled =>
      nameController.text.length > 2 &&
      nameValidation(nameController.text) &&
      (needsQuantity
          ? quantityController.text != '' &&
              quantityValidation(quantityController.text.toInt())
          : true) &&
      (needsDecimal
          ? decimalController.text != '' &&
              decimalValidation(decimalController.text.toInt())
          : true) &&
      (isNFT ? ipfsController.text != '' : true) &&
      parentValidation(parentController.text) &&
      ipfsValidation(ipfsController.text);

  void submit() {
    if (enabled) {
      FocusScope.of(context).unfocus();

      /// send them to transaction checkout screen
      checkout(GenericCreateRequest(
        name: nameController.text,
        ipfs: ipfsController.text,
        quantity: needsQuantity ? quantityController.text.toInt() : null,
        decimals: needsDecimal ? decimalController.text.toInt() : null,
        reissuable: needsReissue ? reissueValue : null,
        verifier: needsVerifier ? verifierController.text : null,
        parent: isSub ? parentController.text : null,
      ));
    }
  }

  String fullName([bool full = false]) => (isSub && full)
      ? parentController.text +
          (isNFT ? '#' : (isChannel ? '~' : (isQualifier ? '/#' : '/'))) +
          nameController.text
      : ((isQualifier || isNFT)
              ? '#'
              : (isChannel ? '~' : (isRestricted ? '\$' : ''))) +
          nameController.text;

  void checkout(GenericCreateRequest createRequest) {
    /// send request to the correct stream
    //streams.spend.make.add(createRequest);

    /// go to confirmation page
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: {
        'struct': CheckoutStruct(
          /// full symbol name
          symbol: fullName(true),
          displaySymbol: nameController.text,
          subSymbol: '',
          paymentSymbol: 'RVN',
          items: [
            /// send the correct items
            if (isSub) ['Name', fullName(true), '2'],
            if (!isSub) ['Name', fullName(), '2'],
            if (needsQuantity) ['Quantity', quantityController.text],
            if (needsDecimal) ['Decimals', decimalController.text],
            if (ipfsController.text != '')
              ['IPFS/Txid', ipfsController.text, '9'],
            if (needsVerifier)
              ['Verifier String', verifierController.text, '6'],
            if (needsReissue) ['Reissuable', reissueValue ? 'Yes' : 'No', '3'],
          ],
          fees: [
            // Standard / Fast transaction, will pull from settings?
            ['Sandard Transaction', 'calculating fee...'],
            isNFT
                ? ['NFT', '5']
                : isChannel
                    ? ['Message Channel', '100']
                    : isQualifier && isSub
                        ? ['Sub Qualifier Asset', '100']
                        : isSub
                            ? ['Sub Asset', '100']
                            : isMain
                                ? ['Main Asset', '500']
                                : isQualifier
                                    ? ['Qualifier Asset', '1000']
                                    : isRestricted
                                        ? ['Restricted Asset', '1500']
                                        : ['Asset', '500']
          ],
          total: 'calculating total...',
          // produce transaction structure here and the checkout screen will
          // send it up on submit:
          buttonAction: () => null,

          /// send the MainCreate request to the right stream
          //streams.spend.send.add(streams.spend.made.value),
          buttonWord: 'Create',
          loadingMessage: 'Creating Asset',
        )
      },
    );
  }

  void formatName() {
    nameController.text = nameController.text.substring(0, remainingNameLength);
    if (nameController.text.endsWith('_') ||
        nameController.text.endsWith('.')) {
      nameController.text =
          nameController.text.substring(0, nameController.text.length - 1);
    }
  }

  void formatQuantity() =>
      quantityController.text = quantityController.text.isInt
          ? quantityController.text.toInt().toCommaString()
          : quantityController.text;

  void _produceParentModal() {
    SelectionItems(context, modalSet: SelectionSet.Parents).build(
        holdingNames: Current.adminNames
            .map((String name) => name.replaceAll('!', ''))
            .toList());
  }

  void _produceQualifierParentModal() {
    SelectionItems(context, modalSet: SelectionSet.Parents).build(
        holdingNames:
            Current.qualifierNames.map((String name) => name).toList());
  }

  void _produceDecimalModal() {
    SelectionItems(context, modalSet: SelectionSet.Decimal)
        .build(decimalPrefix: quantityController.text);
  }

  void _produceAdminAssetModal() {
    SelectionItems(context, modalSet: SelectionSet.Admins).build(
        holdingNames: Current.adminNames
            .where((String name) => !name.contains('/'))
            .map((String name) => name.replaceAll('!', ''))
            .toList());
  }
}
