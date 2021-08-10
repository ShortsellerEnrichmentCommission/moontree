class Accounts {
  Map<String, String> accounts = {};

  static final Accounts _singleton = Accounts._();
  static Accounts get instance => _singleton;
  Accounts._();

  /// can we replace with purely reactive listeners?
  Future<void> load() async {
    Future.delayed(Duration(seconds: 3));
    accounts['accountId1'] = 'Primary';
    accounts['accountId2'] = 'Savings';
    accounts['accountId3'] = 'Other';
  }
}
