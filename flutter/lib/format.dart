// Форматирование граммов: без лишних знаков, с запятой как в русском языке
String fmtGrams(double x) {
  if (!x.isFinite || x <= 0) return '0';
  if (x >= 10) return x.round().toString();
  final r = (x * 10).round() / 10;
  final text = r == r.roundToDouble() ? r.toInt().toString() : r.toStringAsFixed(1);
  return text.replaceAll('.', ',');
}

// Килограммы с дробной частью до 3 знаков (1 г = 0,001 кг), лишние нули убираются
String fmtKg(double grams) {
  if (!grams.isFinite || grams <= 0) return '0';
  var s = (grams / 1000).toStringAsFixed(3);
  s = s.replaceFirst(RegExp(r'0+$'), '');
  s = s.replaceFirst(RegExp(r'\.$'), '');
  return s.replaceAll('.', ',');
}
