import '../constants/app_strings.dart';

/// Date and time helpers.
///
/// Kept free of Flutter imports so it stays trivially unit-testable, and takes
/// an injectable `now` so tests never depend on the wall clock.
abstract final class AppDateUtils {
  /// The time-of-day greeting shown on Home (PRD §9).
  static String greeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return AppStrings.greetingMorning;
    if (hour < 17) return AppStrings.greetingAfternoon;
    return AppStrings.greetingEvening;
  }

  /// Relative label for library and history rows: "Today", "Yesterday",
  /// "3 days ago", then an absolute date.
  static String relativeLabel(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final days = _dateOnly(reference).difference(_dateOnly(date)).inDays;

    return switch (days) {
      <= 0 => 'Today',
      1 => 'Yesterday',
      < 7 => '$days days ago',
      < 14 => 'Last week',
      < 30 => '${days ~/ 7} weeks ago',
      _ => formatDate(date),
    };
  }

  /// "12 August 2026" — unabbreviated, matching the app's unhurried tone.
  static String formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// True when both timestamps fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      _dateOnly(a) == _dateOnly(b);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
