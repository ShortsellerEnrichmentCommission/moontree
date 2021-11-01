/// don't forget to empty the backlog when used.

import 'dart:async';

import 'package:raven/raven.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'waiter.dart';

/// new address -> put in subscriptionHandles -> setup up subscription
/// new subscriptionHandle -> setup up subscription to blockchain
/// subscription -> retrieve data from blockchain

class AddressSubscriptionWaiter extends Waiter {
  final loggedInFlag = false;
  late int id = 0;

  Set<Address> backlogSubscriptions = {};
  Set<Address> backlogRetrievals = {};
  //Set<Address> backlogAddressCipher = {};
  Set<Address> backlogWalletsToUpdate = {};

  Future deinitSubscriptionHandles() async {
    for (var listener in services.client.subscribe.subscriptionHandles.values) {
      await listener.cancel();
    }
    services.client.subscribe.subscriptionHandles.clear();
  }

  void setupClientListener() {
    listen('subjects.client.stream', subjects.client.stream, (client) async {
      if (client == null) {
        await deinitSubscriptionHandles();
      } else {
        backlogSubscriptions.forEach((address) {
          if (!services.client.subscribe.subscriptionHandles.keys
              .contains(address.addressId)) {
            services.client.subscribe
                .to(client as RavenElectrumClient, address);
          }
        });
        backlogSubscriptions.clear();
        services.client.subscribe
            .toExistingAddresses(client as RavenElectrumClient);
        if (backlogRetrievals.isNotEmpty) {
          unawaited(
              retrieveAndMakeNewAddress(client, backlogRetrievals.toList()));
          backlogRetrievals.clear();
        }
      }
    });
  }

  //void setupCipherListener() {
  //  listen('ciphers.batchedChanges', ciphers.batchedChanges,
  //      (List<Change<Cipher>> batchedChanges) async {
  //    if (backlogAddressCipher.isNotEmpty) {
  //      var temp = <Address>{};
  //      for (var changedAddress in backlogAddressCipher) {
  //        var wallet = changedAddress.wallet!;
  //        if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
  //          services.wallet.leader.maybeSaveNewAddress(
  //              wallet as LeaderWallet,
  //              ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
  //              changedAddress.exposure);
  //        } else {
  //          temp.add(changedAddress);
  //        }
  //      }
  //      backlogAddressCipher = temp;
  //    }
  //  });
  //}

  void init() {
    setupSubscriptionsListener();
    setupClientListener();
    //setupCipherListener();
    setupNewAddressListener();
  }

  void setupSubscriptionsListener() {
    listen(
        'addressesNeedingUpdate',
        services.client.subscribe.addressesNeedingUpdate.stream
            .bufferCountTimeout(10, Duration(milliseconds: 50)),
        (changedAddresses) {
      var client = services.client.mostRecentRavenClient;
      if (client == null) {
        for (var address in changedAddresses as List<Address>) {
          backlogRetrievals.add(address);
        }
      } else {
        unawaited(retrieveAndMakeNewAddress(
            client, changedAddresses as List<Address>));
      }
    });
  }

  Future retrieveAndMakeNewAddress(
      RavenElectrumClient client, List<Address> changedAddresses) async {
    await retrieve(client, changedAddresses);

    /// this should be handled by listening to vouts in the leader waiter now:
    //for (var changedAddress in changedAddresses) {
    //  var wallet = changedAddress.wallet!;
    //  if (wallet is LeaderWallet) {
    //    if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
    //      services.wallet.leader.maybeSaveNewAddress(
    //          wallet,
    //          ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
    //          changedAddress.exposure);
    //    } else {
    //      backlogAddressCipher.add(changedAddress);
    //    }
    //  }
    //}
  }

  Future retrieve(
      RavenElectrumClient client, List<Address> changedAddresses) async {
    var msg = 'Downloading transactions for ${changedAddresses.length} '
        'address${changedAddresses.length == 1 ? '' : 'es'}...';
    services.busy.clientOn(msg);
    await services.address.getAndSaveTransactionsByAddresses(
      changedAddresses,
      client,
    );
    services.busy.clientOff(msg);
  }

  void setupNewAddressListener() {
    listen('addresses.batchedChanges', addresses.batchedChanges,
        (List<Change> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
            added: (added) async {
              Address address = added.data;
              var client = services.client.mostRecentRavenClient;
              if (client == null) {
                backlogSubscriptions.add(address);
              } else {
                services.client.subscribe.to(client, address);
              }
            },
            updated: (updated) {},
            removed: (removed) {
              services.client.subscribe.unsubscribe(removed.id as String);
            });
      });
    });
  }
}
