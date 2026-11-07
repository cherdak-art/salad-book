class Ingredient {
  final String name;
  final double grams;
  const Ingredient({required this.name, required this.grams});
}

class Salad {
  final String id;
  final String name;
  final double? finalWeight;
  final List<Ingredient> items;

  const Salad({
    required this.id,
    required this.name,
    this.finalWeight,
    this.items = const [],
  });

  // сумма сырья в партии
  double get rawSum => items.fold(0.0, (s, i) => s + i.grams);

  // вес готового салата: введённый вручную или сумма продуктов
  double get outWeight {
    final f = finalWeight ?? 0;
    return f > 0 ? f : rawSum;
  }

  // сколько грамм продукта уходит на 100 г готового салата
  double per100(double grams) => outWeight > 0 ? grams / outWeight * 100 : 0;

  double get totalPer100 => items.fold(0.0, (s, i) => s + per100(i.grams));

  factory Salad.fromRow(Map<String, dynamic> row) {
    final raw = (row['ingredients'] as List?) ?? const [];
    final rows = raw.map((e) => e as Map<String, dynamic>).toList()
      ..sort((a, b) => (a['position'] as num).compareTo(b['position'] as num));
    return Salad(
      id: row['id'] as String,
      name: row['name'] as String,
      finalWeight: row['final_weight'] == null ? null : (row['final_weight'] as num).toDouble(),
      items: [
        for (final e in rows)
          Ingredient(name: e['name'] as String, grams: (e['grams'] as num).toDouble()),
      ],
    );
  }
}
