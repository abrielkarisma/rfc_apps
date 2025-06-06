import 'package:intl/intl.dart';

class Formatter {
  static String rupiah(int number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(number);
  }
  String formatRupiah(dynamic amount) {
  double numericAmount = 0.0;
  if (amount is String) {
    numericAmount = double.tryParse(amount) ?? 0.0;
  } else if (amount is num) {
    numericAmount = amount.toDouble();
  }
  
  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ', // Saya sesuaikan dengan "Rp. Disini Saldo Toko" Anda
    decimalDigits: 0,
  );
  return formatCurrency.format(numericAmount);
}
}
