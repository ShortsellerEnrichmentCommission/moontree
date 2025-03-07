import 'package:test/test.dart';

import 'package:raven_back/security/cipher_aes.dart';
import 'package:raven_back/security/encrypted_wif.dart';
import 'package:raven_back/extensions/string.dart';

// WIF derived from 'daring field mesh message behave tenant immense shrimp asthma gadget that mammal'
var wif = 'L3H4yjsqop3NY4kncJ6WLsyrhjiCRrvn3xw4pztQgP5EiCeLZ23c';
var cipher = CipherAES('password'.bytes);

void main() {
  group('Encrypted Wallet Entropy', () {
    test('recovers wif', () async {
      var encEnt = EncryptedWIF.fromWIF(wif, cipher);
      expect(encEnt.secret, wif);
    });

    test('has walletId', () async {
      var encEnt = EncryptedWIF.fromWIF(wif, cipher);
      expect(encEnt.walletId,
          '02a702fa47681de96f6d48aec00d10503f9efb1ee9eeb5eaf2ac1776c7fee7223a');
    });
  });
}
