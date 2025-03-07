import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/streams/import.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/services/import.dart';

class Import extends StatefulWidget {
  final dynamic data;
  const Import({this.data}) : super();

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  dynamic data = {};
  FocusNode wordsFocus = FocusNode();
  TextEditingController words = TextEditingController();
  bool importEnabled = false;
  late Wallet wallet;
  String importFormatDetected = '';
  final Backup storage = Backup();
  final TextEditingController password = TextEditingController();
  FileDetails? file;
  String? finalText;
  String? finalAccountId;
  bool importVisible = true;

  @override
  void initState() {
    super.initState();
    wordsFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    wordsFocus.removeListener(_handleFocusChange);
    words.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    if (data['walletId'] == 'current' || data['walletId'] == null) {
      wallet = Current.wallet;
    } else {
      wallet =
          res.wallets.primaryIndex.getOne(data['walletId']) ?? Current.wallet;
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: body(),
    );
  }

  Widget body() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          file == null ? textInputField : filePicked,
          Padding(
              padding:
                  EdgeInsets.only(top: 0, left: 16.0, right: 16.0, bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: file == null
                    ? [
                        Expanded(
                            child: Container(height: 40, child: fileButton)),
                        SizedBox(width: 16),
                        Expanded(
                            child:
                                Container(height: 40, child: submitButton())),
                      ]
                    : [
                        Expanded(
                            child: Container(
                                height: 40, child: submitButton('Import File')))
                      ],
              ))
        ],
      );

  Widget get textInputField => Container(
      height: 200,
      padding: EdgeInsets.only(
        top: 16,
        left: 16.0,
        right: 16.0,
      ),
      child: TextField(
        focusNode: wordsFocus,
        autocorrect: false,
        controller: words,
        obscureText: !importVisible,
        keyboardType: TextInputType.multiline,
        maxLines: importVisible ? 12 : 1,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          focusNode: wordsFocus,
          labelText: wordsFocus.hasFocus ? 'Seed | WIF | Key' : null,
          hintText: 'Please enter your seed words, WIF, or private key.',
          helperText:
              importFormatDetected == 'Unknown' ? null : importFormatDetected,
          errorText:
              importFormatDetected == 'Unknown' ? importFormatDetected : null,
          suffixIcon: IconButton(
            icon: Icon(importVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.black60),
            onPressed: () => setState(() {
              importVisible = !importVisible;
            }),
          ),
        ),
        onChanged: (value) => enableImport(),
        onEditingComplete: () async => await attemptImport(),
      ));

  Widget get filePicked => Column(children: [
        Padding(
            //padding: EdgeInsets.only(left: 8, top: 16.0),
            padding: EdgeInsets.only(left: 16, right: 0, top: 16, bottom: 0),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.attachment_rounded, color: Colors.black),
              title: Text(file!.filename,
                  style: Theme.of(context).textTheme.bodyText1),
              subtitle: Text('${file!.size.toString()} KB',
                  style: Theme.of(context).importedSize),
              trailing: IconButton(
                  icon: Icon(Icons.close_rounded, color: Color(0xDE000000)),
                  onPressed: () => setState(() => file = null)),
            )),
        Divider(),
      ]);

  Widget submitButton([String? label]) => components.buttons.actionButton(
      context,
      enabled: importEnabled,
      label: (label ?? 'Import').toUpperCase(),
      disabledIcon: components.icons.importDisabled(context),
      onPressed: () async => await attemptImport(file?.content ?? words.text));

  Widget get fileButton => components.buttons.actionButton(
        context,
        label: 'File',
        onPressed: () async {
          file = await storage.readFromFilePickerSize();
          enableImport(file?.content ?? '');
          setState(() {});
        },
      );

  void enableImport([String? given]) {
    var oldImportFormatDetected = importFormatDetected;
    var detection =
        services.wallet.import.detectImportType((given ?? words.text).trim());
    importEnabled = detection != null && detection != ImportFormat.invalid;

    if (importEnabled) {
      importFormatDetected =
          'format recognized as ' + detection.toString().split('.')[1];
    } else {
      importFormatDetected = '';
    }
    if (detection == ImportFormat.invalid) {
      importFormatDetected = 'Unknown';
    }
    if (oldImportFormatDetected != importFormatDetected) {
      setState(() => {});
    }
  }

  Future requestPassword() async => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: <Widget>[
              TextField(
                  autocorrect: false,
                  controller: password,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'password',
                  ),
                  onEditingComplete: () {
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit'))
            ],
          ),
        );
      });

  Future attemptImport([String? importData]) async {
    FocusScope.of(context).unfocus();
    var text = (importData ?? words.text).trim();

    /// decrypt if you must...
    if (importData != null) {
      var resp;
      try {
        resp = ImportFrom.maybeDecrypt(
          text: importData,
          cipher: services.cipher.currentCipher!,
        );
      } catch (e) {}
      if (resp == null) {
        // ask for password, make cipher, pass that cipher in.
        // what if it's not the latest cipher type? just try all cipher types...
        for (var cipherType in services.cipher.allCipherTypes) {
          await requestPassword();
          // cancelled
          if (password.text == '') break;
          try {
            resp = ImportFrom.maybeDecrypt(
                text: importData,
                cipher: CipherReservoir.cipherInitializers[cipherType]!(
                    services.cipher.getPassword(altPassword: password.text)));
          } catch (e) {}
          if (resp != null) break;
        }
        if (resp == null) {
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Text('Password Not Recognized'),
                  content: Text(
                      'Password does not match the password used at the time of encryption.')));
          return;
        }
      }
      text = resp;
    }
    streams.import.attempt.add(ImportRequest(text: text));
    components.loading.screen(message: 'Importing');
  }
}
