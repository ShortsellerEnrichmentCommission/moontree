import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/records/cipher_update.dart';
import 'package:raven_back/records/net.dart';
import 'package:raven_back/security/security.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final CipherUpdate cipherUpdate;

  @HiveField(2)
  final String name;

  @override
  List<Object?> get props => [id, cipherUpdate, name];

  Wallet({
    required this.id,
    required this.cipherUpdate,
    String? name,
  }) : name = name ?? id.substring(0, 6);

  String get encrypted;

  String secret(CipherBase cipher);

  WalletBase seedWallet(CipherBase cipher, {Net net = Net.Main});

  SecretType get secretType => SecretType.none;

  WalletType get walletType => WalletType.none;

  String get publicKey => id;

  String get secretTypeToString => secretType.enumString;
  String get walletTypeToString => walletType.enumString;
}
