class DateFormatter {
  static String formatTanggal(String? dateString) {
    if (dateString == null || dateString.isEmpty)
      return 'Tanggal tidak tersedia';
    try {
      DateTime dateTime;

      if (dateString.contains('T') &&
          (dateString.endsWith('Z') || dateString.contains('+'))) {
        dateTime = DateTime.parse(dateString).toLocal();
      } else {
        dateTime = DateTime.parse(dateString);
      }
      final days = [
        '',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      final months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];

      final dayName = days[dateTime.weekday];
      final monthName = months[dateTime.month];
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$dayName, ${dateTime.day} $monthName ${dateTime.year} - $hour:$minute';
    } catch (e) {
      if (dateString.contains('T')) {
        try {
          final parts = dateString.split('T');
          final datePart = parts[0];
          final timePart = parts[1].replaceAll('Z', '').split('.')[0];
          final dateTime = DateTime.parse('${datePart}T$timePart').toLocal();

          final days = [
            '',
            'Senin',
            'Selasa',
            'Rabu',
            'Kamis',
            'Jumat',
            'Sabtu',
            'Minggu'
          ];
          final months = [
            '',
            'Januari',
            'Februari',
            'Maret',
            'April',
            'Mei',
            'Juni',
            'Juli',
            'Agustus',
            'September',
            'Oktober',
            'November',
            'Desember'
          ];

          final dayName = days[dateTime.weekday];
          final monthName = months[dateTime.month];
          final hour = dateTime.hour.toString().padLeft(2, '0');
          final minute = dateTime.minute.toString().padLeft(2, '0');

          return '$dayName, ${dateTime.day} $monthName ${dateTime.year} - $hour:$minute';
        } catch (e) {
          return 'Format tanggal tidak valid';
        }
      }
      return 'Format tanggal tidak valid';
    }
  }

  static String formatTanggalSingkat(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Tgl tidak tersedia';
    try {
      DateTime dateTime;

      if (dateString.contains('T') &&
          (dateString.endsWith('Z') || dateString.contains('+'))) {
        dateTime = DateTime.parse(dateString).toLocal();
      } else {
        dateTime = DateTime.parse(dateString);
      }

      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];

      final monthName = months[dateTime.month];
      return '${dateTime.day} $monthName ${dateTime.year}';
    } catch (e) {
      if (dateString.contains('T')) {
        try {
          final parts = dateString.split('T');
          final datePart = parts[0];
          final timePart = parts[1].replaceAll('Z', '').split('.')[0];
          final dateTime = DateTime.parse('${datePart}T$timePart').toLocal();

          final months = [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'Mei',
            'Jun',
            'Jul',
            'Agu',
            'Sep',
            'Okt',
            'Nov',
            'Des'
          ];

          final monthName = months[dateTime.month];
          return '${dateTime.day} $monthName ${dateTime.year}';
        } catch (e) {
          return 'Tgl tidak valid';
        }
      }
      return 'Tgl tidak valid';
    }
  }

  static String formatJam(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      DateTime dateTime;

      if (dateString.contains('T') &&
          (dateString.endsWith('Z') || dateString.contains('+'))) {
        dateTime = DateTime.parse(dateString).toLocal();
      } else {
        dateTime = DateTime.parse(dateString);
      }

      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      if (dateString.contains('T')) {
        try {
          final parts = dateString.split('T');
          final timePart = parts[1].replaceAll('Z', '').split('.')[0];
          final dateTime = DateTime.parse('${parts[0]}T$timePart').toLocal();

          final hour = dateTime.hour.toString().padLeft(2, '0');
          final minute = dateTime.minute.toString().padLeft(2, '0');
          return '$hour:$minute';
        } catch (e) {
          return '';
        }
      }
      return '';
    }
  }

  static String formatTanggalCard(String? dateString) {
    final tanggal = formatTanggalSingkat(dateString);
    final jam = formatJam(dateString);
    if (tanggal == 'Tgl tidak tersedia' || jam.isEmpty) {
      return tanggal;
    }
    return '$tanggal $jam';
  }

  static String formatRelativeTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Waktu tidak tersedia';
    try {
      DateTime dateTime;
      if (dateString.contains('T') &&
          (dateString.endsWith('Z') || dateString.contains('+'))) {
        dateTime = DateTime.parse(dateString).toLocal();
      } else {
        dateTime = DateTime.parse(dateString);
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return formatTanggalSingkat(dateString);
    }
  }
}
