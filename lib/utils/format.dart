import 'package:intl/intl.dart';

String fmtNum(double v) {
  final decimals = v == v.roundToDouble() ? 0 : 1;
  return NumberFormat.decimalPatternDigits(decimalDigits: decimals).format(v);
}

String fmtRatio(double ratio) {
  return '1:${fmtNum(ratio)}';
}

String fmtDuration(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String fmtLongDuration(int totalSeconds) {
  if (totalSeconds >= 3600) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }
  if (totalSeconds >= 60) {
    final minutes = fmtNum(totalSeconds / 60.0);
    return '${minutes}m';
  }
  return '${totalSeconds}s';
}

String fmtDate(DateTime d) {
  return DateFormat('d MMM y', 'en_US').format(d);
}
