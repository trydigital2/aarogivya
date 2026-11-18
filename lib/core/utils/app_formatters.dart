import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  static final _date = DateFormat('EEE, MMM d, y');
  static final _time = DateFormat('h:mm a');
  static final _dateTime = DateFormat('MMM d, y • h:mm a');

  static String currency(num value) => _currency.format(value);
  static String date(DateTime value) => _date.format(value.toLocal());
  static String time(DateTime value) => _time.format(value.toLocal());
  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());
  static String initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}
