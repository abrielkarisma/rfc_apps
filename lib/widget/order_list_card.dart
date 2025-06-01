import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/widget/badge_status.dart'; 

class OrderListCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onTap;

  const OrderListCard({
    Key? key,
    required this.order,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? orderId = order['id'] as String?;
    final String? createdAt = order['createdAt'] as String?;
    final List<dynamic>? pesananDetails =
        order['PesananDetails'] as List<dynamic>?;

    String displayOrderId = orderId?.substring(0, 8) ?? 'N/A';
    String formattedDate = 'N/A';
    String orderStatus = order['status'] ?? '';
    if (createdAt != null) {
      try {
        final DateTime dateTime = DateTime.parse(createdAt);
        formattedDate =
            DateFormat('dd MMMM yyyy HH:mm').format(dateTime.toLocal());
      } catch (e) {
        print('Error parsing date in OrderListCard: $e');
      }
    }

    String productName = 'Produk Tidak Ditemukan';
    String productQuantity = '';
    String productImageUrl = '';
    int otherProductsCount = 0;

    if (pesananDetails != null && pesananDetails.isNotEmpty) {
      final firstDetail = pesananDetails[0] as Map<String, dynamic>;
      final Map<String, dynamic>? produk =
          firstDetail['Produk'] as Map<String, dynamic>?;
      if (produk != null) {
        productName = produk['nama'] ?? 'Produk Tidak Ditemukan';
        productQuantity =
            '${firstDetail['jumlah'] ?? '0'} ${produk['satuan'] ?? ''}';
        productImageUrl = produk['gambar'] ?? '';
      }
      otherProductsCount = pesananDetails.length - 1;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2), 
          width: 1, // Optional border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ID Pesanan : ${displayOrderId}",
                  style: const TextStyle(
                    fontFamily: "poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontFamily: "poppins",
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ShimmerImage(
                    imageUrl: productImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontFamily: "poppins",
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        productQuantity,
                        style: const TextStyle(
                          fontFamily: "poppins",
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (otherProductsCount > 0)
                        Text(
                          "+$otherProductsCount Produk Lainnya",
                          style: const TextStyle(
                            fontFamily: "poppins",
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 20, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: onTap,
                child: Text(
                  "Lihat Selengkapnya",
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              orderStatus == "selesai"
                  ? StatusBadge(
                      status: orderStatus,
                    )
                  : orderStatus == "ditolak"
                      ? StatusBadge(
                          status: orderStatus,
                        )
                      : const SizedBox.shrink(),
            ]),
          ],
        ),
      ),
    );
  }
}
