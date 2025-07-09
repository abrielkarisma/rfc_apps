import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/view/penjual/produk/edit_produk.dart';

class DetailProdukPage extends StatefulWidget {
  const DetailProdukPage({super.key, required this.id_produk});
  final String id_produk;

  @override
  _DetailProdukPageState createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  String $gambar = "";
  String $nama = "";
  String $harga = "";
  String $stok = "";
  String $satuan = "";
  String $deskripsi = "";
  String $id_produk = "";

  @override
  void initState() {
    super.initState();
    _getDataProduk();
  }

  Future<void> _getDataProduk() async {
    try {
      final response = await ProdukService().getProdukById(widget.id_produk);
      setState(() {
        $nama = response.data[0].nama;
        $harga = response.data[0].harga.toString();
        $stok = response.data[0].stok.toString();
        $satuan = response.data[0].satuan;
        $deskripsi = response.data[0].deskripsi;
        $gambar = response.data[0].gambar;
        $id_produk = response.data[0].id;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Rooftop Farming Center.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: "Monserrat_Alternates",
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/homebackground.png',
              fit: BoxFit.fitHeight,
            ),
          ),

          // Content with RefreshIndicator
          RefreshIndicator(
            onRefresh: _getDataProduk,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title
                    Container(
                      padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: MediaQuery.of(context).padding.top + 56),
                      child: const Text(
                        "Detail Produk",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: context.getHeight(60),
                    ),

                    Center(
                      child: Container(
                        width: context.getWidth(320),
                        height: context.getHeight(320),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4CAD73).withOpacity(0.8),
                              Colors.white.withOpacity(0.8),
                              Color(0xFF4CAD73).withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Color(0xFF4CAD73).withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: $gambar.isNotEmpty
                                  ? Image(
                                      image: NetworkImage($gambar),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF4CAD73),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: context.getHeight(20),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildDetailRow("Nama Produk", $nama),
                          _buildDetailRow("Deskripsi Produk", $deskripsi),
                          _buildDetailRow("Stok Produk", $stok),
                          _buildDetailRow("Satuan Produk", $satuan),
                          _buildDetailRow("Harga Produk", $harga),

                          SizedBox(height: context.getHeight(40)),

                          // Action buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _deleteProduk();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFF4D37),
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Hapus Produk",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProduk(
                                            id: $id_produk,
                                            nama: $nama,
                                            harga: $harga,
                                            stok: $stok,
                                            satuan: $satuan,
                                            deskripsi: $deskripsi,
                                            gambar: $gambar,
                                          ),
                                        ),
                                      );
                                      if (result == 'refresh') {
                                        await _getDataProduk();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CAD73),
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Edit Produk",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom indicator line
                          Container(
                            width: 100,
                            height: 4,
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            " : ",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduk() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Konfirmasi Hapus",
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus produk ini?",
            style: TextStyle(
              fontFamily: "Poppins",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Batal",
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Poppins",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop(); // Close dialog first

                try {
                  final response =
                      await ProdukService().deleteProduk($id_produk);
                  print(response);
                  if (response.message == "Successfully deleted produk data") {
                    if (mounted) {
                      // Return to previous page with refresh signal
                      navigator.pop('refresh');
                      print("Navigating back with refresh signal");
                    }
                  } else {
                    print("Failed to delete product: ${response.message}");
                  }
                } catch (e) {
                  print("Error deleting product: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF4D37),
              ),
              child: Text(
                "Hapus",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
