/// Parses Chinese week-expression strings into sorted lists of week numbers.
///
/// Supported formats:
///   "1-16"        → [1..16]
///   "1-16单周"    → [1,3,5..15]
///   "1-16双周"    → [2,4,6..16]
///   "1,3,5,7"     → [1,3,5,7]
///   "1-4,6,8-10"  → [1,2,3,4,6,8,9,10]
class WeekParser {
  static List<int> parse(String expression) {
    if (expression.trim().isEmpty) return [];
    final result = <int>{};

    final segments = expression
        .split(RegExp(r'[,，]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    for (final seg in segments) {
      // Strip section info like (1-2节) or （1-2节）
      var s = seg
          .replaceAll(RegExp(r'\([0-9]+-[0-9]+节?\)'), '')
          .replaceAll(RegExp(r'（[0-9]+-[0-9]+节?）'), '')
          .trim();

      final isOdd = s.contains('单') || s.contains('(单)') || s.contains('（单）');
      final isEven = s.contains('双') || s.contains('(双)') || s.contains('（双）');

      // Extract numeric part
      final numberPart = s
          .replaceAll(RegExp(r'[^0-9\-]'), ' ')
          .trim()
          .split(RegExp(r'\s+'))
          .firstWhere((p) => p.isNotEmpty, orElse: () => '');

      if (numberPart.isEmpty) continue;

      if (numberPart.contains('-')) {
        final parts = numberPart.split('-');
        if (parts.length == 2) {
          final start = int.tryParse(parts[0]);
          final end = int.tryParse(parts[1]);
          if (start != null && end != null) {
            for (var w = start; w <= end; w++) {
              if (isOdd && w.isOdd) result.add(w);
              else if (isEven && w.isEven) result.add(w);
              else if (!isOdd && !isEven) result.add(w);
            }
          }
        }
      } else {
        final w = int.tryParse(numberPart);
        if (w != null) result.add(w);
      }
    }

    return result.toList()..sort();
  }

  /// Convert a week list back to a compact display string.
  static String format(List<int> weeks) {
    if (weeks.isEmpty) return '';
    final sorted = [...weeks]..sort();
    final ranges = <String>[];
    int start = sorted[0];
    int end = sorted[0];
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i] == end + 1) {
        end = sorted[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end');
        start = sorted[i];
        end = sorted[i];
      }
    }
    ranges.add(start == end ? '$start' : '$start-$end');
    return '${ranges.join(',')}周';
  }
}
