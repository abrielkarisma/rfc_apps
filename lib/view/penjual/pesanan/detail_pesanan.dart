import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/service/pesanan.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/imagePicker.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class DetailPesanan extends StatefulWidget {
  final Map<String, dynamic> order;

  const DetailPesanan({super.key, required this.order});

  @override
  State<DetailPesanan> createState() => _DetailPesananState();
}

class _DetailPesananState extends State<DetailPesanan> {
  late String _profilePhoto = "";
  bool uloadedBukti = false;
  @override
  void initState() {
    super.initState();
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return "Rp. 0";
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(amount);
  }

  Future<void> _pickImage() async {
    ImagePickerHelper.showImageSourceOptions(
      context,
      onImageSelected: (File image) {
        setState(() {
          _profilePhoto = image.path;
        });
      },
    );
  }

  void _tolakPesanan() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Tolak Pesanan",
              style: TextStyle(
                fontFamily: "poppins",
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black87,
              )),
          content: Text("Apakah Anda yakin ingin menolak pesanan ini?",
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 16,
                color: Colors.black87,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await PesananService().putStatusPesanan(
                  widget.order['id'],
                  'ditolak',
                );
                Navigator.pop(context);
                Navigator.pop(context, 'refresh');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Tolak",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "poppins",
                    fontSize: 14,
                  )),
            ),
          ],
        );
      },
    );
  }

  void _pesananSiap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Pesanan Siap",
              style: TextStyle(
                fontFamily: "poppins",
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black87,
              )),
          content: Text("Apakah Anda ingin menandai pesanan ini siap diambil?",
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 16,
                color: Colors.black87,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await PesananService().putStatusPesanan(
                  widget.order['id'],
                  'diterima',
                );
                Navigator.pop(context);
                Navigator.pop(context, 'refresh');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor),
              child: Text("Siap",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "poppins",
                    fontSize: 14,
                  )),
            ),
          ],
        );
      },
    );
  }

  void _siapDiambil() {
    if (_profilePhoto.isEmpty) {
      ToastHelper.showErrorToast(
          context, "Silakan unggah bukti pengambilan terlebih dahulu.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Pesanan Sudah Diambil",
              style: TextStyle(
                fontFamily: "poppins",
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black87,
              )),
          content: Text("Apakah Anda yakin pesanan ini sudah diambil?",
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 16,
                color: Colors.black87,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final file = File(_profilePhoto);
                  if (!file.existsSync()) {
                    throw Exception('File gambar tidak ditemukan.');
                  }

                  final cloudinaryService = CloudinaryService();
                  final uploadResult =
                      await cloudinaryService.getUploadUrl(file);

                  final uploadedPhotoUrl = uploadResult['url'];
                  final buktiResult = await PesananService()
                      .createBuktiPengambilan(
                          widget.order['id'], uploadedPhotoUrl);
                  final putStatus = await PesananService().putStatusPesanan(
                    widget.order['id'],
                    'selesai',
                  );
                  final pendapatan = await PesananService().addPendapatan(
                      widget.order['id'], widget.order['totalHarga']);
                  if (buktiResult['message'] ==
                          "Bukti diterima berhasil dibuat" &&
                      putStatus['message'] ==
                          "Status pesanan berhasil diperbarui") {
                    ToastHelper.showSuccessToast(
                        context, "Pesanan Berhasil Diselesaikan");
                  } else {
                    ToastHelper.showErrorToast(context,
                        "Gagal menyelesaikan pesanan: ${buktiResult['message']}");
                  }
                  Navigator.pop(context);
                } catch (e) {
                  Navigator.pop(context);
                }
                Navigator.pop(context, 'refresh');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text("Sudah",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "poppins",
                    fontSize: 14,
                  )),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> orderData = widget.order;

    final String? orderId = orderData['id'] as String?;
    final String? createdAt = orderData['createdAt'] as String?;
    final int? totalHarga = orderData['totalHarga'] as int?;
    final List<dynamic>? pesananDetails =
        orderData['PesananDetails'] as List<dynamic>?;
    final Map<String, dynamic>? user =
        orderData['User'] as Map<String, dynamic>?;
    String StatusPesanan = orderData['status'] as String? ?? '';
    String displayOrderId = orderId?.substring(0, 8) ?? '';
    String formattedDate = '';
    if (createdAt != null) {
      try {
        final DateTime dateTime = DateTime.parse(createdAt);
        formattedDate = DateFormat('dd MMMM HH:mm').format(dateTime.toLocal());
      } catch (e) {
        print('Error parsing date in DetailPesanan: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "poppins",
                fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/homebackground.png',
              fit: BoxFit.fill,
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: context.getHeight(200),
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  children: [
                    _buildInfoRow("Tanggal Pembelian", formattedDate),
                    _buildInfoRow("ID Pesanan", displayOrderId),
                  ],
                ),
                SizedBox(height: 20),
                _buildSectionCard(
                  title: "Daftar Produk",
                  children: [
                    if (pesananDetails != null && pesananDetails.isNotEmpty)
                      ...pesananDetails.map((detailRaw) {
                        final Map<String, dynamic> detail =
                            detailRaw as Map<String, dynamic>;
                        final Map<String, dynamic>? produk =
                            detail['Produk'] as Map<String, dynamic>?;
                        if (produk == null) return SizedBox.shrink();

                        final String productName =
                            produk['nama'] ?? 'Unknown Product';
                        final int quantity = detail['jumlah'] ?? 0;
                        final int hargaPerProduk = produk['harga'] ?? 0;
                        final String productImageUrl = produk['gambar'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: ShimmerImage(
                                  imageUrl: productImageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: TextStyle(
                                        fontFamily: "poppins",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '$quantity ${produk['satuan'] ?? ''}',
                                      style: TextStyle(
                                        fontFamily: "poppins",
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatCurrency(quantity * hargaPerProduk),
                                style: TextStyle(
                                  fontFamily: "poppins",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    Divider(),
                    _buildInfoRow("Total Harga", _formatCurrency(totalHarga)),
                  ],
                ),
                SizedBox(height: 20),
                _buildSectionCard(
                  title: "Profil Pembeli",
                  children: [
                    _buildInfoRow("Nama Pembeli", user?['name'] ?? ''),
                  ],
                ),
                SizedBox(height: context.getHeight(20)),
                StatusPesanan == "diterima"
                    ? _buildSectionCard(
                        title: "Tambah Bukti Pengambilan",
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: _profilePhoto.isEmpty
                                  ? Container(
                                      width: context.getWidth(100),
                                      height: context.getHeight(100),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.add_a_photo,
                                          size: 50, color: Colors.grey),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_profilePhoto),
                                        width: context.getWidth(150),
                                        height: context.getHeight(150),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          )
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: StatusPesanan == "menunggu"
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _tolakPesanan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              "Tolak Pesanan",
                              style: TextStyle(
                                fontFamily: "poppins",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pesananSiap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              "Pesanan Siap",
                              style: TextStyle(
                                fontFamily: "poppins",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : StatusPesanan == "diterima"
                      ? Container(
                          child: Expanded(
                            child: ElevatedButton(
                              onPressed: _siapDiambil,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                "Sudah Diambil",
                                style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          child: Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, 'refresh');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                "Kembali",
                                style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ))
        ],
      ),
    );
  }

  Widget _buildSectionCard({String? title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          if (title != null) const Divider(height: 10, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "poppins",
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: "poppins",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
