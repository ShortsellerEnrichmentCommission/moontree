import 'package:ravencoin/ravencoin.dart'
    show ECPair, KPWallet, P2PKH, PaymentData;
import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';

class SingleWalletService extends Service {
  late AccountReservoir accounts;

  SingleWalletService(this.accounts) : super();

  KPWallet getSingleWallet(SingleWallet wallet, Net net) {
    return KPWallet(
        ECPair.fromPrivateKey(wallet.privateKey,
            network: networks[net]!, compressed: true),
        P2PKH(data: PaymentData(), network: networks[net]!),
        networks[net]!);
  }

  Address toAddress(SingleWallet wallet) {
    var net = accounts.primaryIndex.getOne(wallet.accountId)!.net;
    var seededWallet = getSingleWallet(wallet, net);
    return Address(
        scripthash: seededWallet.scripthash,
        address: seededWallet.address!,
        walletId: wallet.walletId,
        hdIndex: 0,
        net: net);
  }
}
