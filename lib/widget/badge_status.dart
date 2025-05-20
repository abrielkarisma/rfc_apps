import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusStyle(status);
    //cara panggil
//     OrderStatusBadge(status: 'request'),
// OrderStatusBadge(status: 'active'),
// OrderStatusBadge(status: 'delete'),
// OrderStatusBadge(status: 'reject'),

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusData['background'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusData['label'] as String,
        style: TextStyle(
          fontFamily: "Poppins",
          color: statusData['textColor'] as Color,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'belum dibayar':
        return {
          'label': 'Belum Dibayar',
          'background': Colors.amber.shade100,
          'textColor': Colors.amber.shade800,
        };
      case 'menunggu':
        return {
          'label': 'Menunggu',
          'background': Colors.grey.shade300,
          'textColor': Colors.grey.shade800,
        };
      case 'siap diambil':
        return {
          'label': 'Siap Diambil',
          'background': Colors.orange.shade100,
          'textColor': Colors.orange,
        };
      case 'selesai':
        return {
          'label': 'Selesai',
          'background': Colors.green.shade100,
          'textColor': Colors.green.shade700,
        };
      case 'ditolak':
        return {
          'label': 'Ditolak',
          'background': Colors.red.shade100,
          'textColor': Colors.red.shade700,
        };
      case 'request':
        return {
          'label': 'Request',
          'background': Colors.blue.shade100,
          'textColor': Colors.blue.shade700,
        };
      case 'active':
        return {
          'label': 'Active',
          'background': Colors.lightGreen.shade100,
          'textColor': Colors.lightGreen.shade800,
        };
      case 'delete':
        return {
          'label': 'Delete',
          'background': Colors.black12,
          'textColor': Colors.black,
        };
      case 'reject':
        return {
          'label': 'Reject',
          'background': Colors.red.shade100,
          'textColor': Colors.red,
        };
      default:
        return {
          'label': 'Status Tidak Dikenal',
          'background': Colors.black12,
          'textColor': Colors.black87,
        };
    }
  }
}
