/// Kullanıcının kaydettiği özel kahve reçetesi.
class CoffeeRecipe {
  final String id;
  final String name;
  final String methodName;
  final double coffeeGrams;
  final double waterMl;
  final double ratio; // 1:X
  final String grindSize;
  final int waterTempC;
  final int totalTimeSeconds;
  final String notes;
  final DateTime createdAt;

  const CoffeeRecipe({
    required this.id,
    required this.name,
    required this.methodName,
    required this.coffeeGrams,
    required this.waterMl,
    required this.ratio,
    required this.grindSize,
    required this.waterTempC,
    required this.totalTimeSeconds,
    required this.notes,
    required this.createdAt,
  });

  CoffeeRecipe copyWith({
    String? name,
    String? methodName,
    double? coffeeGrams,
    double? waterMl,
    double? ratio,
    String? grindSize,
    int? waterTempC,
    int? totalTimeSeconds,
    String? notes,
  }) {
    return CoffeeRecipe(
      id: id,
      name: name ?? this.name,
      methodName: methodName ?? this.methodName,
      coffeeGrams: coffeeGrams ?? this.coffeeGrams,
      waterMl: waterMl ?? this.waterMl,
      ratio: ratio ?? this.ratio,
      grindSize: grindSize ?? this.grindSize,
      waterTempC: waterTempC ?? this.waterTempC,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'methodName': methodName,
        'coffeeGrams': coffeeGrams,
        'waterMl': waterMl,
        'ratio': ratio,
        'grindSize': grindSize,
        'waterTempC': waterTempC,
        'totalTimeSeconds': totalTimeSeconds,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CoffeeRecipe.fromJson(Map<String, dynamic> json) => CoffeeRecipe(
        id: json['id'] as String,
        name: json['name'] as String,
        methodName: json['methodName'] as String,
        coffeeGrams: (json['coffeeGrams'] as num).toDouble(),
        waterMl: (json['waterMl'] as num).toDouble(),
        ratio: (json['ratio'] as num).toDouble(),
        grindSize: json['grindSize'] as String,
        waterTempC: json['waterTempC'] as int,
        totalTimeSeconds: json['totalTimeSeconds'] as int,
        notes: json['notes'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
