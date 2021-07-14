import '../../raven_electrum_client.dart';

class ScripthashStats {
  late double ourCost;
  late int hardLimit;
  late int softLimit;
  late double costDecayPerSec;
  late double bandwithCostPerByte;
  late double sleep;
  late int concurrentRequests;
  late int sendSize;
  late int sendCount;
  late int receiveSize;
  late int receiveCount;
  ScripthashStats(
      this.ourCost,
      this.hardLimit,
      this.softLimit,
      this.costDecayPerSec,
      this.bandwithCostPerByte,
      this.sleep,
      this.concurrentRequests,
      this.sendSize,
      this.sendCount,
      this.receiveSize,
      this.receiveCount);

  @override
  List<Object> get props => [
        ourCost,
        hardLimit,
        softLimit,
        costDecayPerSec,
        bandwithCostPerByte,
        sleep,
        concurrentRequests,
        sendSize,
        sendCount,
        receiveSize,
        receiveCount
      ];

  @override
  String toString() {
    return '''ScripthashBalance( 
    ourCost: $ourCost, 
    hardLimit: $hardLimit, 
    softLimit: $softLimit, 
    costDecayPerSec: $costDecayPerSec, 
    bandwithCostPerByte: $bandwithCostPerByte, 
    sleep: $sleep, 
    concurrentRequests: $concurrentRequests, 
    sendSize: $sendSize, 
    sendCount: $sendCount, 
    receiveSize: $receiveSize, 
    receiveCount: $receiveCount)''';
  }
}

extension GetOurStatsMethod on RavenElectrumClient {
  Future<dynamic> getOurStats() async {
    var proc = 'server.our_stats';
    dynamic stats = await request(proc);
    return ScripthashStats(
      stats['our_cost'],
      stats['hard_limit'],
      stats['soft_limit'],
      stats['cost_decay_per_sec'],
      stats['bandwith_cost_per_byte'],
      stats['sleep'],
      stats['concurrent_requests'],
      stats['send_size'],
      stats['send_count'],
      stats['receive_size'],
      stats['receive_count'],
    );
  }
}
