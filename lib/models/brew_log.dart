/// Bir demleme günlüğü kaydı.
class BrewLogEntry {
  final String id;
  final DateTime date;
  final String methodName;
  final double coffeeGrams;
  final double waterMl;
  final double ratio; // 1:X
  final String grindSize;
  final int waterTempC;
  final int brewTimeSeconds;
  final int rating; // 1..5
  final String notes;

  const BrewLogEntry({
    required this.id,
    required this.date,
    required this.methodName,
    required this.coffeeGrams,
    required this.waterMl,
    required this.ratio,
    required this.grindSize,
    required this.waterTempC,
    required this.brewTimeSeconds,
    required this.rating,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'methodName': methodName,
        'coffeeGrams': coffeeGrams,
        'waterMl': waterMl,
        'ratio': ratio,
        'grindSize': grindSize,
        'waterTempC': waterTempC,
        'brewTimeSeconds': brewTimeSeconds,
        'rating': rating,
        'notes': notes,
      };

  factory BrewLogEntry.fromJson(Map<String, dynamic> json) => BrewLogEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        methodName: json['methodName'] as String,
        coffeeGrams: (json['coffeeGrams'] as num).toDouble(),
        waterMl: (json['waterMl'] as num).toDouble(),
        ratio: (json['ratio'] as num).toDouble(),
        grindSize: json['grindSize'] as String,
        waterTempC: json['waterTempC'] as int,
        brewTimeSeconds: json['brewTimeSeconds'] as int,
        rating: json['rating'] as int,
        notes: json['notes'] as String? ?? '',
      );
}
