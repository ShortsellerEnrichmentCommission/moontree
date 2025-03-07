export 'logo.dart';

import 'package:raven_front/listeners/logo.dart';

// globals
final LogoListener logoListener = LogoListener();
final AssetListener assetListener = AssetListener();

void initListeners() {
  /// don't pull logos or any ipfs data for mvp
  //logoListener.init();
  assetListener.init();
}
