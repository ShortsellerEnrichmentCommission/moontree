import 'address.dart';
import 'subscription.dart';
import 'block.dart';
import 'client.dart';
import 'history.dart';
import 'import.dart';
import 'leader.dart';
import 'password.dart';
import 'rate.dart';
import 'send.dart';
import 'setting.dart';
import 'single.dart';

class waiters {
  static AddressWaiter address = AddressWaiter();
  static SubscriptionWaiter subscription = SubscriptionWaiter();
  static BlockWaiter block = BlockWaiter();
  static ImportWaiter import = ImportWaiter();
  static HistoryWaiter history = HistoryWaiter();
  static PasswordWaiter password = PasswordWaiter();
  static RateWaiter rate = RateWaiter();
  static RavenClientWaiter client = RavenClientWaiter();
  static SendWaiter send = SendWaiter();
  static SettingWaiter setting = SettingWaiter();
  // Wallets
  static LeaderWaiter leader = LeaderWaiter();
  static SingleWaiter single = SingleWaiter();
}
