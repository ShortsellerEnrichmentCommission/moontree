import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show hex;
import 'package:sorted_list/sorted_list.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:ravencoin/ravencoin.dart';

import '../boxes.dart';
import '../cipher.dart';
import '../derivation_path.dart';
import '../records.dart' as records;
import '../records/net.dart';
import '../models.dart' as models;

extension on HDWallet {
  Uint8List get outputScript {
    return Address.addressToOutputScript(address!, network)!;
  }

  String get scripthash {
    var digest = sha256.convert(outputScript);
    var hash = digest.bytes.reversed.toList();
    return hex.encode(hash);
  }

  ECPair get keyPair {
    return ECPair.fromWIF(wif!, networks: ravencoinNetworks);
  }
}

class CacheEmpty implements Exception {
  String cause;
  CacheEmpty([this.cause = 'Error! Please deriveNodes first.']);
}

class InsufficientFunds implements Exception {
  String cause;
  InsufficientFunds([this.cause = 'Error! Insufficient funds.']);
}

class nodeLocation {
  int index;
  records.NodeExposure exposure;

  nodeLocation(int locationIndex, records.NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

const DEFAULT_CIPHER = NoCipher();

class Account extends Equatable {
  // Taken from records.Account
  final Uint8List encryptedSeed;
  final records.Net net;
  final String name;

  final records.Account? record;
  late final String accountId;
  late final HDWallet seededWallet;
  late final Cipher cipher;

  @override
  List<Object?> get props => encryptedSeed;

  Account(seed,
      {this.name = 'Wallet',
      this.net = Net.Test,
      this.record,
      this.cipher = const NoCipher()})
      : accountId = sha256.convert(seed).toString(),
        encryptedSeed = cipher.encrypt(seed) {
    seededWallet = HDWallet.fromSeed(seed, network: network);
  }

  factory Account.fromEncryptedSeed(encryptedSeed,
      {name = 'Wallet', net = Net.Test, record, cipher = const NoCipher()}) {
    return Account(cipher.decrypt(encryptedSeed),
        name: name, net: net, record: record, cipher: cipher);
  }

  factory Account.fromRecord(records.Account record,
      {cipher = const NoCipher()}) {
    return Account(cipher.decrypt(record.encryptedSeed),
        name: record.name, net: record.net, record: record, cipher: cipher);
  }

  records.Account toRecord() {
    return records.Account(encryptedSeed, net: net, name: name);
  }

  @override
  String toString() {
    return 'Account($name, $accountId)';
  }

  //// getters /////////////////////////////////////////////////////////////////

  NetworkType get network => networks[net]!;

  int get balance => Truth.instance.getAccountBalance(this);

  //// Account Scripthashes ////////////////////////////////////////////////////

  List<String> get accountInternals {
    var ounordered = Truth.instance.scripthashAccountIdInternal
        .filterKeysByValueString(accountId)
        .toList();
    var orders =
        Truth.instance.scripthashOrderInternal.filterAllByKeys(ounordered);
    var keys = orders.keys.toList(growable: false)
      ..sort((k1, k2) => orders[k1]!.compareTo(orders[k2]!));
    return keys
        .map((element) => element as String)
        .toList(); // List<dynamic> -> List<String>
  }

  /// why should we care if externals are ordered? we'll be consistent
  List<String> get accountExternals {
    var ounordered = Truth.instance.scripthashAccountIdExternal
        .filterKeysByValueString(accountId)
        .toList();
    var orders =
        Truth.instance.scripthashOrderExternal.filterAllByKeys(ounordered);
    var keys = orders.keys.toList(growable: false)
      ..sort((k1, k2) => orders[k1]!.compareTo(orders[k2]!));
    return keys
        .map((element) => element as String)
        .toList(); // List<dynamic> -> List<String>
    // unordered
    //return Truth.instance.scripthashAccountIdExternal
    //    .filterKeysByValueString(accountId);
  }

  List<String> get accountScripthashes {
    return [...accountInternals, ...accountExternals];
  }

  /// returns the next internal or external node without a history
  HDWallet getNextEmptyWallet(
      [records.NodeExposure exposure = records.NodeExposure.Internal]) {
    // ensure valid exposure
    exposure = exposure == records.NodeExposure.Internal
        ? records.NodeExposure.Internal
        : records.NodeExposure.External;
    var i = 0;
    for (var scripthash in exposure == records.NodeExposure.Internal
        ? accountInternals
        : accountExternals) {
      if (Truth.instance.histories
          .getAsList<ScripthashHistory>(scripthash)
          .isEmpty) {
        return deriveWallet(i, exposure);
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return deriveWallet(i, exposure);
  }

  //// Derive Wallet ///////////////////////////////////////////////////////////

  HDWallet deriveWallet(int hdIndex,
      [exposure = records.NodeExposure.External]) {
    return seededWallet.derivePath(
        getDerivationPath(hdIndex, exposure: exposure, wif: network.wif));
  }

  models.Address deriveAddress(int hdIndex, records.NodeExposure exposure) {
    var wallet = deriveWallet(hdIndex, exposure);
    return models.Address(
        wallet.scripthash, wallet.address!, accountId, hdIndex,
        exposure: exposure, net: net);
  }

  /// probably not necessary...
  Future deriveBatch(int hdIndex, records.NodeExposure exposure,
      [int batchSize = 10]) async {
    var addresses = [];
    for (var i = 0; i < batchSize; i++) {
      addresses.add(deriveAddress(hdIndex, exposure));
      hdIndex = hdIndex + 1;
    }
    return addresses;
  }

  //// Sending Functionality ///////////////////////////////////////////////////

  SortedList<ScripthashUnspent> sortedUTXOs() {
    var sortedList = SortedList<ScripthashUnspent>(
        (ScripthashUnspent a, ScripthashUnspent b) =>
            a.value.compareTo(b.value));
    sortedList.addAll(
        Truth.instance.accountUnspents.getAsList<ScripthashUnspent>(accountId));
    return sortedList;
  }

  /// returns the smallest number of inputs to satisfy the amount
  List<ScripthashUnspent> collectUTXOs(int amount,
      [List<ScripthashUnspent>? except]) {
    var ret = <ScripthashUnspent>[];

    if (balance < amount) {
      throw InsufficientFunds();
    }
    var utxos = sortedUTXOs();
    utxos.removeWhere((utxo) => (except ?? []).contains(utxo));

    /* can we find an ideal singular utxo? */
    for (var i = 0; i < utxos.length; i++) {
      if (utxos[i].value >= amount) {
        return [utxos[i]];
      }
    }

    /* what combinations of utxo's must we return?
    lets start by grabbing the largest one
    because we know we can consume it all without producing change...
    and lets see how many times we can do that */
    var remainder = amount;
    for (var i = utxos.length - 1; i >= 0; i--) {
      if (remainder < utxos[i].value) {
        break;
      }
      ret.add(utxos[i]);
      remainder = (remainder - utxos[i].value).toInt();
    }
    // Find one last UTXO, starting from smallest, that satisfies the remainder
    ret.add(utxos.firstWhere((utxo) => utxo.value >= remainder));
    return ret;
  }

  nodeLocation? getNodeLocationOf(scripthash) {
    var i = 0;
    for (var internalScripthash in accountInternals) {
      if (internalScripthash == scripthash) {
        return nodeLocation(i, records.NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var internalScripthash in accountExternals) {
      if (internalScripthash == scripthash) {
        return nodeLocation(i, records.NodeExposure.External);
      }
      i = i + 1;
    }
  }
}
