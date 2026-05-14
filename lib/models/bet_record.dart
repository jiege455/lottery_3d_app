class BetRecord {
  final int? id;
  final String number;
  final String playType;
  final String playTypeName;
  final int lotteryType;
  final double multiplier;
  final double baseAmount;
  final String batchId;
  final DateTime createTime;
  final bool paidStatus;

  BetRecord({
    this.id,
    required this.number,
    required this.playType,
    required this.playTypeName,
    this.lotteryType = 1,
    this.multiplier = 1.0,
    this.baseAmount = 2.0,
    this.batchId = '',
    DateTime? createTime,
    this.paidStatus = false,
  }) : createTime = createTime ?? DateTime.now();

  double get totalAmount => baseAmount * multiplier;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'number': number,
      'play_type': playType,
      'play_type_name': playTypeName,
      'lottery_type': lotteryType,
      'multiplier': multiplier,
      'base_amount': baseAmount,
      'batch_id': batchId,
      'create_time': createTime.toIso8601String(),
      'paid_status': paidStatus ? 1 : 0,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory BetRecord.fromMap(Map<String, dynamic> map) {
    return BetRecord(
      id: map['id'] as int?,
      number: (map['number'] ?? '') as String,
      playType: (map['play_type'] ?? '') as String,
      playTypeName: (map['play_type_name'] ?? '') as String,
      lotteryType: (map['lottery_type'] ?? 1) as int,
      multiplier: (map['multiplier'] ?? 1.0) as double,
      baseAmount: (map['base_amount'] ?? 2.0) as double,
      batchId: (map['batch_id'] ?? '') as String,
      paidStatus: (map['paid_status'] ?? 0) == 1,
      createTime: map['create_time'] != null
          ? (DateTime.tryParse(map['create_time'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  BetRecord copyWith({
    int? id,
    String? number,
    String? playType,
    String? playTypeName,
    int? lotteryType,
    double? multiplier,
    double? baseAmount,
    String? batchId,
    DateTime? createTime,
    bool? paidStatus,
  }) {
    return BetRecord(
      id: id ?? this.id,
      number: number ?? this.number,
      playType: playType ?? this.playType,
      playTypeName: playTypeName ?? this.playTypeName,
      lotteryType: lotteryType ?? this.lotteryType,
      multiplier: multiplier ?? this.multiplier,
      baseAmount: baseAmount ?? this.baseAmount,
      batchId: batchId ?? this.batchId,
      createTime: createTime ?? this.createTime,
      paidStatus: paidStatus ?? this.paidStatus,
    );
  }
}
