// Форматирование граммов: без лишних знаков, с запятой как в русском языке
String fmtGrams(double x) {
  if (!x.isFinite || x <= 0) return '0';
  if (x >= 10) return x.round().toString();
  final r = (x * 10).round() / 10;
  final text = r == r.roundToDouble() ? r.toInt().toString() : r.toStringAsFixed(1);
  return text.replaceAll('.', ',');
}
