import 'package:raven/raven.dart';

String currentAccountId() => settings.currentAccountId;

Account currentAccount() => accounts.primaryIndex.getOne(currentAccountId())!;

BalanceUSD currentBalanceUSD() => ratesService
    .accountBalanceUSD(currentAccountId(), holdings: currentHoldings());

Balance currentBalanceRVN() =>
    balanceService.accountBalance(currentAccount(), RVN);
//balances.getOrZero(currentAccountId());

/// our concept of history isn't the same as transactions - must fill out negative values for sent amounts
List<History> currentTransactions() =>
    histories.byAccount.getAll(currentAccountId()).toList();

List<Balance> currentHoldings() =>
    balanceService.accountBalances(currentAccount());

List<Balance> currentWalletHoldings(String walletId) =>
    balanceService.walletBalances(wallets.primaryIndex.getOne(walletId)!);

BalanceUSD currentWalletBalanceUSD(String walletId) => ratesService
    .accountBalanceUSD(walletId, holdings: currentWalletHoldings(walletId));

List<History> currentWalletTransactions(String walletId) =>
    histories.byWallet.getAll(walletId).toList();

class Current {
  static Account get account => currentAccount();
  static Balance get balanceRVN => currentBalanceRVN();
  static BalanceUSD get balanceUSD => currentBalanceUSD();
  static List<History> get transactions => currentTransactions();
  static List<Balance> get holdings => currentHoldings();
  static BalanceUSD walletBalanceUSD(String walletId) =>
      currentWalletBalanceUSD(walletId);
  static List<Balance> walletHoldings(String walletId) =>
      currentWalletHoldings(walletId);
  static List<History> walletTransactions(String walletId) =>
      currentWalletTransactions(walletId);
}
