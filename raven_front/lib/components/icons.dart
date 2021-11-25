import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven/records/records.dart';
import 'package:fnv/fnv.dart';
import 'package:raven_mobile/services/storage.dart';

import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/widgets/circle_gradient.dart';

class IconComponents {
  IconComponents();

  Icon get back => Icon(Icons.arrow_back, color: Colors.grey[100]);

  Icon income(BuildContext context) =>
      Icon(Icons.south_west, size: 12.0, color: Theme.of(context).good);

  Icon out(BuildContext context) =>
      Icon(Icons.north_east, size: 12.0, color: Theme.of(context).bad);

  Icon importDisabled(BuildContext context) =>
      Icon(Icons.add_box_outlined, color: Theme.of(context).disabledColor);

  Icon get import => Icon(Icons.add_box_outlined);

  Icon get export => Icon(Icons.save);

  Image get assetMasterImage => Image.asset('assets/masterbag_transparent.png');
  Image get assetRegularImage => Image.asset('assets/assetbag_transparent.png');

  Widget assetAvatar(String asset) {
    if (asset.toUpperCase() == 'RVN') {
      return _assetAvatarRVN();
    }
    try {
      // this is in try because the firsrt time it download it may not have
      // finished saving before it is called upon to be used:
      /*══╡ EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE ╞════════════════════════════════════════════════════
        The following FileSystemException was thrown resolving an image codec:
        Cannot open file, path =
        '/data/user/0/com.rvnbag.ravenmobile/app_flutter/images/QmXe1VJjmBi1Tjti8mUa2UyScvEPyUnhSGSZzwD19kCYUm'
        (OS Error: No such file or directory, errno = 2)

        When the exception was thrown, this was the stack:
        #0      _File.open.<anonymous closure> (dart:io/file_impl.dart:356:9)
        <asynchronous suspension>
        #2      FileImage._loadAsync (package:flutter/src/painting/image_provider.dart:890:29)
        <asynchronous suspension>
        (elided one frame from dart:async)
      */
      var ret = _assetAvatarSecurity(asset);
      if (ret != null) {
        return ret;
      }
    } catch (e) {
      print(e);
    }
    return _assetAvatarGenerated(asset);
  }

  /// if it's RVN we know what to do...
  Widget _assetAvatarRVN() => Image.asset('assets/rvn.png');

  /// if it's an asset lets see if it has a custom logo...
  /// Notice: this is untested as we don't yet have a logo in the metadata...
  Widget? _assetAvatarSecurity(String symbol) {
    var security =
        securities.bySymbolSecurityType.getOne(symbol, SecurityType.RavenAsset);
    if (security != null &&
        !([null, '']).contains(security.asset?.logo?.data)) {
      try {
        return Image.file(AssetLogos().readLogoFileNow(
            security.asset?.logo?.data ?? '',
            settings.primaryIndex.getOne(SettingName.Local_Path)!.value));
      } catch (e) {
        print(
            'unable to open image asset file for ${security.asset?.logo?.data}: $e');
      }
    }
  }

  /// no logo? no problem, we'll make one...
  /// Remove the `!` when calculating hash, so each master asset
  /// matches its corresponding regular asset autogenerated colors
  Widget _assetAvatarGenerated(String asset) {
    var i = fnv1a_64(asset.codeUnits);
    if (asset.endsWith('!')) {
      i = fnv1a_64(asset.substring(0, asset.length - 1).codeUnits);
      return moneybag(gradients[i % gradients.length], assetMasterImage);
    }
    return moneybag(gradients[i % gradients.length], assetRegularImage);
  }

  Widget moneybag(ColorPair background, Image foreground) =>
      Stack(children: [PopCircle(colorPair: background), foreground]);

  CircleAvatar appAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar accountAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar walletAvatar(Wallet wallet) => wallet is LeaderWallet
      ? CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'))
      : CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));
}
