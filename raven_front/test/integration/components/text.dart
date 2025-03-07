import 'package:flutter_test/flutter_test.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/text.dart';
import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final Security security =
      Security(symbol: 'MOONTREE', securityType: SecurityType.RavenAsset);
  final textC = TextComponents();

  group('securityAsReadable', () {
    setUp(fixtures.useFixtureSources);
    tearDown(fixtures.deleteDatabase);

    test('asset amount without divisibility', () {
      expect(textC.securityAsReadable(0, symbol: 'MOONTREE'), '0');
      expect(textC.securityAsReadable(123, symbol: 'MOONTREE'), '123');
      expect(textC.securityAsReadable(123, security: security), '123');
    });

    test('asset amount with divisibilty', () async {
      await res.assets.save(Asset(
          symbol: 'MOONTREE',
          satsInCirculation: 1000,
          divisibility: 2,
          reissuable: false,
          metadata: '',
          transactionId: '',
          position: 0));
      expect(textC.securityAsReadable(0, symbol: 'MOONTREE'), '0');
      expect(textC.securityAsReadable(123, symbol: 'MOONTREE'), '1.23');
      expect(textC.securityAsReadable(123, security: security), '1.23');
    });

    test('asset to RVN then to USD without rate', () {
      // no rate known (requires additioanl integration tests)
      expect(textC.securityAsReadable(0, symbol: 'MOONTREE', asUSD: true),
          r'$ 0.00');
      expect(textC.securityAsReadable(123, symbol: 'MOONTREE', asUSD: true),
          r'$ 0.00');
      expect(textC.securityAsReadable(123, security: security, asUSD: true),
          r'$ 0.00');
    });

    test('asset to RVN then to USD with rate (and divisibility)', () async {
      await res.assets.save(Asset(
          symbol: 'MOONTREE',
          satsInCirculation: 1000,
          divisibility: 2,
          reissuable: false,
          metadata: '',
          transactionId: '',
          position: 0));
      await res.rates.saveAll([
        Rate(
            base: Security(symbol: 'RVN', securityType: SecurityType.Crypto),
            quote: Security(symbol: 'USD', securityType: SecurityType.Fiat),
            rate: 3.0),
        Rate(
            base: Security(
                symbol: 'MOONTREE', securityType: SecurityType.RavenAsset),
            quote: Security(symbol: 'RVN', securityType: SecurityType.Crypto),
            rate: 2.0),
      ]);
      // 123 -> divisibility 2 -> 1.23 moontrees -> 2.46 ravens -> 7.38 dollars
      expect(textC.securityAsReadable(0, symbol: 'MOONTREE', asUSD: true),
          r'$ 0.00');
      expect(textC.securityAsReadable(123, symbol: 'MOONTREE', asUSD: true),
          r'$ 7.38');
      expect(textC.securityAsReadable(123, security: security, asUSD: true),
          r'$ 7.38');
    });

    test('RVN to USD without rate', () async {
      expect(textC.rvnUSD(0), r'$ 0.00');
      expect(textC.rvnUSD(123), r'$ 0.00');
      expect(textC.rvnUSD(123), r'$ 0.00');
    });

    test('RVN to USD with rate', () async {
      await res.rates.save(Rate(
          base: Security(symbol: 'RVN', securityType: SecurityType.Crypto),
          quote: Security(symbol: 'USD', securityType: SecurityType.Fiat),
          rate: 3.0));
      // 123 ravens -> 3.69 dollars
      expect(textC.rvnUSD(0), r'$ 0.00');
      expect(textC.rvnUSD(1.23), r'$ 3.69');
      expect(textC.rvnUSD(123), r'$ 369.00');
    });
  });
}
