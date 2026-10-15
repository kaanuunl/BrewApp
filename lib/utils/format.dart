/// Sayıları Türkçe biçimde (virgüllü) güzel göster.
String fmtNum(double v) {
  if (v == v.roundToDouble()) {
    return v.toInt().toString();
  }
  final s = v.toStringAsFixed(1);
  return s.replaceAll('.', ',').replaceFirst(RegExp(r',0$'), '');
}

/// Oranı "1:16" biçiminde göster.
String fmtRatio(double ratio) {
  final r = ratio == ratio.roundToDouble()
      ? ratio.toInt().toString()
      : ratio.toStringAsFixed(1).replaceAll('.', ',');
  return '1:$r';
}

/// Süreyi "1:30" / "2:30" biçiminde göster (saniye -> m:ss).
String fmtDuration(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Uzun süreleri insan dostu göster (ör. "12 saat", "4 dk").
String fmtLongDuration(int totalSeconds) {
  if (totalSeconds >= 3600) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    return m > 0 ? '$h sa $m dk' : '$h saat';
  }
  if (totalSeconds >= 60) {
    return '${fmtNum(totalSeconds / 60.0)} dk';
  }
  return '$totalSeconds sn';
}

const _monthsTr = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

/// Tarihi "15 Eki 2026" biçiminde göster.
String fmtDate(DateTime d) {
  return '${d.day} ${_monthsTr[d.month - 1]} ${d.year}';
}
