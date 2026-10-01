import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: 'TL',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
