abstract final class FirestoreValues {
  static DateTime date(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? optionalDate(dynamic value) =>
      value == null ? null : date(value);

  static String string(dynamic value, [String fallback = '']) =>
      value is String ? value : fallback;

  static num number(dynamic value, [num fallback = 0]) =>
      value is num ? value : fallback;

  static bool boolean(dynamic value, [bool fallback = false]) =>
      value is bool ? value : fallback;

  static List<String> stringList(dynamic value) => value is List
      ? value.whereType<String>().toList(growable: false)
      : const <String>[];

  static Map<String, dynamic> map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}
