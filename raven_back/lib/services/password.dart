import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:raven/raven.dart';
import 'package:raven/utils/transform.dart';

class PasswordService {
  final PasswordValidationService validate = PasswordValidationService();
  final PasswordCreationService create = PasswordCreationService();

  bool get passwordRequired => passwords.maxPasswordID != -1;

  bool interruptedPasswordChange() => {
        for (var cipherUpdate in services.wallets.getAllCipherUpdates)
          if (cipherUpdate.passwordId != passwords.maxPasswordID)
            cipherUpdate.passwordId
      }.isNotEmpty;

  void get broadcastLogin => subjects.login.sink.add(true);
  void get broadcastLogout => subjects.login.sink.add(false);
}

class PasswordValidationService {
  String getHash(String password, String salt) => services.passwords.create
      .hashThis(services.passwords.create.saltPassword(password, salt));

  bool password(String password) =>
      getHash(password, passwords.primaryIndex.getMostRecent()!.salt) ==
      passwords.primaryIndex.getMostRecent()!.saltedHash;

  bool previousPassword(String password) =>
      getHash(password, passwords.primaryIndex.getPrevious()!.salt) ==
      passwords.primaryIndex.getPrevious()!.saltedHash;

  /// returns the number corresponding to how many passwords ago this was used
  /// -1 = not found
  /// 0 = current
  /// 1 = previous
  /// "password was used x passwords ago"
  int previouslyUsed(String password) {
    var m = passwords.maxPasswordID;
    for (var pass in passwords.data) {
      if (getHash(password, pass.salt) == pass.saltedHash) {
        return m - pass.passwordId;
      }
    }
    return -1;
  }

  bool complexity(String password) =>
      password.length >= 12 &&
      any([
        for (var i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
          password.contains(i.toString())
      ]);
}

class PasswordCreationService {
  String saltPassword(String password, String salt) => '$salt$password';

  String hashThis(String saltedPassword) {
    var bytes = utf8.encode(saltedPassword);
    var digest = sha256.convert(bytes);
    //print('Digest as bytes: ${digest.bytes}');
    //print('Digest as hex string: $digest');
    return digest.toString();
  }

  /// save password in reservoir
  Future save(String password) async {
    await passwords.save(Password(
        passwordId: passwords.maxPasswordID + 1,
        saltedHash: hashThis(saltPassword(
            password, Password.getSalt(passwords.maxPasswordID + 1)))));
  }
}
