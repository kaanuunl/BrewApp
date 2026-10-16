class GrinderCalibration {
  const GrinderCalibration({
    required this.grinderName,
    required this.unit,
    required this.settings,
    required this.updatedAt,
  });

  final String grinderName;
  final String unit;
  final Map<String, String> settings;
  final DateTime updatedAt;

  String? settingFor(String methodId) => settings[methodId];

  Map<String, dynamic> toJson() => {
        'grinderName': grinderName,
        'unit': unit,
        'settings': settings,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory GrinderCalibration.fromJson(Map<String, dynamic> json) {
    final rawSettings = json['settings'] as Map<String, dynamic>? ?? {};
    final unit = json['unit'] as String? ?? 'clicks';
    return GrinderCalibration(
      grinderName: json['grinderName'] as String? ?? '',
      unit: unit == 'klik' ? 'clicks' : unit,
      settings: rawSettings.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
