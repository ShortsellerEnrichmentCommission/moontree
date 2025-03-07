/// when activity is detected on an address we download a list of txids (its history)
/// this picks it up and saves them by wallet-exposure. We wait till no history was
/// found for that wallet-exposure then we go download all the transactions for it.
/// doing so allows us to know when we should calculate the balance for it: right
/// after all the transactions are downloaded for that wallet-exposure...

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/wallet.dart';
import 'waiter.dart';

class HistoryWaiter extends Waiter {
  Map<String, List<String>> txsByWalletExposureKeys = {};

  void init() => listen(
      'streams.address.history',
      streams.wallet.transactions,
      (WalletExposureTransactions? keyedTransactions) =>
          keyedTransactions == null
              ? doNothing(/* initial state */)
              : keyedTransactions.transactionIds.isEmpty
                  ? pull(keyedTransactions)
                  : remember(keyedTransactions));

  void doNothing() {}

  void remember(WalletExposureTransactions keyedTransactions) =>
      txsByWalletExposureKeys[keyedTransactions.key] =
          (txsByWalletExposureKeys[keyedTransactions.key] ?? []) +
              keyedTransactions.transactionIds.toList();

  Future<void> pull(WalletExposureTransactions keyedTransactions) async {
    var txs = txsByWalletExposureKeys.containsKey(keyedTransactions.key)
        ? txsByWalletExposureKeys[keyedTransactions.key]
        : null;
    if (txs != null) {
      txsByWalletExposureKeys[keyedTransactions.key] = [];
      await getTransactionsAndCalculateBalance(
          keyedTransactions.walletId, keyedTransactions.exposure, txs);
    }
  }

  // if we could get a batch of transactions that'd be better...
  Future<void> getTransactionsAndCalculateBalance(
    String walletId,
    NodeExposure exposure,
    Iterable<String> transactionIds,
  ) async {
    for (var transactionId in transactionIds) {
      await getTransaction(transactionId);
    }
    // calculate balances (for that wallet exposure)
    //var done =
    //    await services.history.produceAddressOrBalanceFor(walletId, exposure);
    await services.history.produceAddressOrBalance();
  }

  Future getTransaction(String transaction) async =>
      await services.history.getTransaction(transaction);
}
