class BetRecord {
  final int? id;
  final String number;
  final String playType;
  final String playTypeName;
  int lotteryType;
  double multiplier;
  final DateTime createTime;

  BetRecord({
    this.id,
    required this.number,
    required this.playType,
    required this.playTypeName,
    this.lotteryType = 1,
    this.multiplier = 1.0,
    DateTime? createTime,
  }) : createTime = createTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'play_type': playType,
      'play_type_name': playTypeName,
      'lottery_type': lotteryType,
      'multiplier': multiplier,
      'create_time': createTime.toIso8601String(),
    };
  }

  factory BetRecord.fromMap(Map<String, dynamic> map) {
    return BetRecord(
      id: map['id'],
      number: map['number'] ?? '',
      playType: map['play_type'] ?? 'single',
      playTypeName: map['play_type_name'] ?? '直选',
      lotteryType: map['lottery_type'] ?? 1,
      multiplier: (map['multiplier'] ?? 1.0).toDouble(),
      createTime: map['create_time'] != null ? (DateTime.tryParse(map['create_time']) ?? DateTime.now()) : DateTime.now(),
    );
  }

  BetRecord copyWith({
    int? id,
    String? number,
    String? playType,
    String? playTypeName,
    int? lotteryType,
    double? multiplier,
    DateTime? createTime,
  }) {
    return BetRecord(
      id: id ?? this.id,
      number: number ?? this.number,
      playType: playType ?? this.playType,
      playTypeName: playTypeName ?? this.playTypeName,
      lotteryType: lotteryType ?? this.lotteryType,
      multiplier: multiplier ?? this.multiplier,
      createTime: createTime ?? this.createTime,
    );
  }
}
