class AppSettings {
  double defaultMultiplier;
  int defaultLotteryType;
  String lastBackupTime;

  AppSettings({
    this.defaultMultiplier = 1.0,
    this.defaultLotteryType = 1,
    this.lastBackupTime = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'default_multiplier': defaultMultiplier,
      'default_lottery_type': defaultLotteryType,
      'last_backup_time': lastBackupTime,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      defaultMultiplier: (map['default_multiplier'] ?? 1.0).toDouble(),
      defaultLotteryType: map['default_lottery_type'] ?? 1,
      lastBackupTime: map['last_backup_time'] ?? '',
    );
  }
}
