import 'package:raven/reactives.dart';
import 'package:raven/subjects/reservoir.dart';

import 'models.dart';
import 'records/node_exposure.dart';

late Reservoir accounts;
late Reservoir addresses;
late Reservoir subscriptions;
late Reservoir reports;

void setup2() {
  accounts = Reservoir(
      HiveBoxSource('accounts'),
      (account) => account.accountId,
      (account) => Account.fromRecord(account),
      (account) => account.toRecord());

  addresses = Reservoir(
      HiveBoxSource('addresses'),
      (address) => address.scripthash,
      (address) => Address.fromRecord(address),
      (address) => address.toRecord())
    ..addIndex('account', (address) => address.accountId)
    ..addIndex('account-exposure',
        (address) => '${address.accountId}:${address.exposure}');

  // ? subscriptions = Reservoir(
  // ?     HiveBoxSource('subscriptions'),
  // ?     (address) => address.scripthash,
  // ?     (address) => Address.fromRecord(address),
  // ?     (address) => address.toRecord())
  // ?   ..addIndex('account', (address) => address.accountId)
  // ?   ..addIndex('account-exposure',
  // ?       (address) => '${address.accountId}:${address.exposure}');

  reports = Reservoir(HiveBoxSource('reports'), (report) => report.scripthash,
      (report) => Report.fromRecord(report), (report) => report.toRecord())
    ..addIndex('scripthash', (report) => report.scripthash);
  // can we index it by accountId?

  accounts.changes.listen((change) {
    change.when(added: (added) {
      Account account = added.data;

      // is this how we get size (later)?
      // Also if this is how we're going to do it,
      // we need to clear addresses first...
      //var internalHDIndex = addresses.indices['account-exposure']!
      //    .size('${account.accountId}:${NodeExposure.Internal}');
      //var externalHDIndex = addresses.indices['account-exposure']!
      //    .size('${account.accountId}:${NodeExposure.Internal}');

      var addr1 = account.deriveAddress(0, NodeExposure.Internal);
      var addr2 = account.deriveAddress(0, NodeExposure.External);

      // is this how we save?
      //addresses.save(addr1); ?
      //addresses.save(addr2); ?
    }, updated: (updated) {
      // what's going to change on the account? only the name?
    }, removed: (removed) {
      // - unsubscribe from addresses (scripthash)
      // - delete in-memory addresses
      // - delete in-memory balances, histories, unspents
      // - UI updates
      // - remove from database if it exists
      //   - Truth.instance.removeScripthashesOf(event.value.accountId);
      //   - Truth.instance.accountUnspents.delete(event.value.accountId);
    });
  });

  addresses.changes.listen((change) {
    change.when(added: (added) {
      Address address = added.data;
      // set up a subscription
      // subscriptions.save(addr1); ?
    }, updated: (updated) {
      // nothing changes
    }, removed: (removed) {
      // if this happens its because the account has been removed...
      // so do the removal steps that make sense here.
    });
  });

  subscriptions.changes.listen((change) {
    change.when(added: (added) {
      //Subscription subscription = added.data;
      //reportBool = getReport(subscription.scripthash, client, exposure??);
      //var report = reportBool[0];
      //var isNotEmpty = report[1];
      //if (isNotEmpty) {
      //   is this how we get size (later)?
      //  var internalHDIndex = addresses.indices['account-exposure']!
      //      .size('${account.accountId}:${exposure??}');
      //  var addr = account.deriveAddress(0, exposure??);
      //  addresses.save(addr); ?
      //}

      // add this address to batch, using rxdart, once batch is big enough,
      // or enough time has passed, do the following with a different watcher on that batch thing:
      // - requestBalances(addressBatch);
      // - requestUnspents(addressBatch);
      // - requestHistories(addressBatch);
      // - save the results of all those to their reservoirs
    }, updated: (updated) {
      //Subscription subscription = updated.data;
      // add this address to batch, using rxdart, once batch is big enough,
      // or enough time has passed, do the following with a different watcher on that batch thing:
      // - requestBalances(addressBatch);
      // - requestUnspents(addressBatch);
      // - requestHistories(addressBatch);
      // - save the results of all those to their reservoirs
    }, removed: (removed) {
      // - unsubscribe from addresses (scripthash)
      // - delete in-memory addresses
      // - delete in-memory balances, histories, unspents
      // - UI updates
      // - remove from database if it exists
      //   - Truth.instance.removeScripthashesOf(event.value.accountId);
      //   - Truth.instance.accountUnspents.delete(event.value.accountId);
    });
  });
}
