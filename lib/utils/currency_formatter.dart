import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Format rupiah dengan symbol dan pengaturan custom
  /// Input: 150000
  /// Output: "Rp 150.000"
  static String formatRupiah(dynamic amount,
      {bool showSymbol = true, bool withSign = false}) {
    double numericAmount = 0.0;
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: showSymbol ? 'Rp ' : '',
      decimalDigits: 0,
    );

    String formatted = formatCurrency.format(numericAmount.abs());
    if (withSign) {
      return (numericAmount >= 0 ? '+ ' : '- ') + formatted;
    }
    return formatted;
  }

  /// Format rupiah tanpa symbol untuk perhitungan
  /// Input: 150000
  /// Output: "150.000"
  static String formatRupiahWithoutSymbol(dynamic amount) {
    return formatRupiah(amount, showSymbol: false);
  }

  /// Format rupiah dengan tanda + atau - untuk mutasi
  /// Input: 150000
  /// Output: "+ Rp 150.000"
  static String formatRupiahWithSign(dynamic amount) {
    return formatRupiah(amount, withSign: true);
  }

  /// Format rupiah kompak untuk display kecil
  /// Input: 1500000
  /// Output: "Rp 1,5 Jt"
  static String formatRupiahCompact(dynamic amount) {
    double numericAmount = 0.0;
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }

    if (numericAmount >= 1000000000) {
      return 'Rp ${(numericAmount / 1000000000).toStringAsFixed(1)} M';
    } else if (numericAmount >= 1000000) {
      return 'Rp ${(numericAmount / 1000000).toStringAsFixed(1)} Jt';
    } else if (numericAmount >= 1000) {
      return 'Rp ${(numericAmount / 1000).toStringAsFixed(1)} Rb';
    } else {
      return formatRupiah(amount);
    }
  }

  /// Parse string rupiah kembali ke number
  /// Input: "Rp 150.000"
  /// Output: 150000.0
  static double parseRupiah(String rupiahString) {
    // Remove Rp, spaces, dots, and commas
    String cleanString = rupiahString
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll('+', '')
        .replaceAll('-', '');

    return double.tryParse(cleanString) ?? 0.0;
  }
}
