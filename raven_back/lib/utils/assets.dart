/// used to aggregate multiple balances into one asset tree
// ignore_for_file: omit_local_variable_types

import 'package:raven_back/raven_back.dart';

List<AssetHolding> assetHoldings(Iterable<Balance> holdings) {
  Map<String, AssetHolding> balancesMain = {};
  Map<String, AssetHolding> balancesSub = {};
  Map<String, AssetHolding> balancesOther = {};
  for (var balance in holdings) {
    var baseSymbol =
        balance.security.asset?.baseSymbol ?? balance.security.symbol;
    var assetType =
        balance.security.asset?.assetType ?? balance.security.securityType;
    if ([AssetType.Main, AssetType.Admin].contains(assetType)) {
      if (!balancesMain.containsKey(baseSymbol)) {
        balancesMain[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          main: assetType == AssetType.Main ? balance : null,
          admin: assetType == AssetType.Admin ? balance : null,
        );
      } else {
        balancesMain[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesMain[baseSymbol]!,
          main: assetType == AssetType.Main ? balance : null,
          admin: assetType == AssetType.Admin ? balance : null,
        );
      }
    } else if ([AssetType.Sub, AssetType.SubAdmin].contains(assetType)) {
      if (!balancesSub.containsKey(baseSymbol)) {
        balancesSub[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          sub: assetType == AssetType.Sub ? balance : null,
          subAdmin: assetType == AssetType.SubAdmin ? balance : null,
        );
      } else {
        balancesSub[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesSub[baseSymbol]!,
          sub: assetType == AssetType.Sub ? balance : null,
          subAdmin: assetType == AssetType.SubAdmin ? balance : null,
        );
      }
    } else {
      if (!balancesOther.containsKey(baseSymbol)) {
        balancesOther[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          nft: assetType == AssetType.NFT ? balance : null,
          channel: assetType == AssetType.Channel ? balance : null,
          restricted: assetType == AssetType.Restricted ? balance : null,
          restrictedAdmin:
              assetType == AssetType.RestrictedAdmin ? balance : null,
          qualifier: assetType == AssetType.Qualifier ? balance : null,
          qualifierSub: assetType == AssetType.QualifierSub ? balance : null,
          crypto: assetType == SecurityType.Crypto ? balance : null,
          fiat: assetType == SecurityType.Fiat ? balance : null,
        );
      } else {
        balancesOther[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesOther[baseSymbol]!,
          nft: assetType == AssetType.NFT ? balance : null,
          channel: assetType == AssetType.Channel ? balance : null,
          restricted: assetType == AssetType.Restricted ? balance : null,
          restrictedAdmin:
              assetType == AssetType.RestrictedAdmin ? balance : null,
          qualifier: assetType == AssetType.Qualifier ? balance : null,
          qualifierSub: assetType == AssetType.QualifierSub ? balance : null,
          crypto: assetType == SecurityType.Crypto ? balance : null,
          fiat: assetType == SecurityType.Fiat ? balance : null,
        );
      }
    }
  }
  return balancesMain.values.toList() +
      balancesSub.values.toList() +
      balancesOther.values.toList();
}

Balance blank(Asset asset) => Balance(
    walletId: '',
    confirmed: 0,
    unconfirmed: 0,
    security: asset.security ??
        Security(securityType: SecurityType.RavenAsset, symbol: asset.symbol));

Map<String, AssetHolding> assetHoldingsFromAssets(String parent) {
  Map<String, AssetHolding> assets = {};
  for (var asset in res.assets) {
    var assetType = asset.assetType;
    if (!assets.containsKey(asset.baseSubSymbol)) {
      assets[asset.baseSubSymbol] = AssetHolding(
        symbol: asset.baseSubSymbol,
        main: assetType == AssetType.Main ? blank(asset) : null,
        admin: assetType == AssetType.Admin ? blank(asset) : null,
        restricted: assetType == AssetType.Restricted ? blank(asset) : null,
        qualifier: assetType == AssetType.Qualifier ? blank(asset) : null,
        nft: assetType == AssetType.NFT ? blank(asset) : null,
        channel: assetType == AssetType.Channel ? blank(asset) : null,
        //crypto: assetType == SecurityType.Crypto ? blank(asset) : null,
        //fiat: assetType == SecurityType.Fiat ? blank(asset) : null,
      );
    } else {
      assets[asset.baseSubSymbol] = AssetHolding.fromAssetHolding(
        assets[asset.baseSubSymbol]!,
        main: assetType == AssetType.Main ? blank(asset) : null,
        admin: assetType == AssetType.Admin ? blank(asset) : null,
        restricted: assetType == AssetType.Restricted ? blank(asset) : null,
        qualifier: assetType == AssetType.Qualifier ? blank(asset) : null,
        nft: assetType == AssetType.NFT ? blank(asset) : null,
        channel: assetType == AssetType.Channel ? blank(asset) : null,
        //crypto: assetType == SecurityType.Crypto ? blank(asset) : null,
        //fiat: assetType == SecurityType.Fiat ? blank(asset) : null,
      );
    }
  }
  return assets;
}
