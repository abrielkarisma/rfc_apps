import 'package:intl/intl.dart';

class Formatter {
  static String rupiah(int number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(number);
  }
}
