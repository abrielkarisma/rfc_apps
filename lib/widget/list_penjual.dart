import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/service/user.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class PenjualTable extends StatefulWidget {
  final List<dynamic> penjualList;
  final bool onDelete;

  const PenjualTable(
      {super.key, required this.penjualList, required this.onDelete});

  @override
  State<PenjualTable> createState() => _PenjualTableState();
}

class _PenjualTableState extends State<PenjualTable> {
  int currentPage = 0;
  int rowsPerPage = 5;
  String searchQuery = '';

  List<dynamic> get filteredList {
    if (searchQuery.isEmpty) return widget.penjualList;
    return widget.penjualList.where((item) {
      return item['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _deleteTokoHandler(String id) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Konfirmasi Hapus"),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus toko ini? ",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
            ),
            child: const Text("Batal"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final response = await tokoService().deleteToko(id);
                if (response['message'] == "Toko Delete successfully") {
                  ToastHelper.showSuccessToast(
                      context, "Toko berhasil dihapus");
                  Navigator.of(context).pop(true);
                } else {
                  ToastHelper.showErrorToast(
                      context, "Gagal menghapus toko: ${response['message']}");
                }
              } catch (e) {
                ToastHelper.showErrorToast(context, "Gagal menghapus toko: $e");
              }
            },
            icon: Icon(Icons.delete, size: 18),
            label: Text("Hapus"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (filteredList.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage < filteredList.length)
        ? start + rowsPerPage
        : filteredList.length;
    final paginatedList = filteredList.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama Toko...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE0F7FA)),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                currentPage = 0;
              });
            },
          ),
        ),
        SingleChildScrollView(
          child: DataTable(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              columnSpacing: 32,
              headingRowColor:
                  MaterialStateProperty.all(const Color(0xFFE0F7FA)),
              columns: [
                DataColumn(
                    label: SizedBox(
                  width: context.getHeight(40),
                  child: Text("Logo",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
                DataColumn(
                    label: SizedBox(
                  width: context.getHeight(140),
                  child: Text("Nama",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
                DataColumn(
                    label: SizedBox(
                  width: context.getHeight(80),
                  child: Text("Aksi",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
              ],
              rows: paginatedList.asMap().entries.map((entry) {
                final index = entry.key + 1 + (currentPage * rowsPerPage);
                final penjual = entry.value;
                return DataRow(cells: [
                  DataCell(
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      backgroundImage: NetworkImage(
                        penjual['Toko']?['logoToko'] ??
                            'https://res.cloudinary.com/do4mvm3ta/image/upload/v1746673871/clxx1mjmoqocslj9ogjh.jpg',
                      ),
                    ),
                  ),
                  DataCell(Text(penjual['Toko']?['nama'] ?? '-')),
                  DataCell(Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _detailTokoHandler(
                              penjual['id'], penjual['Toko']?['id']);
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.transparent,
                            ),
                            child: SvgPicture.asset(
                              'assets/images/round-document.svg',
                              width: 24,
                              height: 24,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.getWidth(8)),
                      widget.onDelete == true
                          ? InkWell(
                              onTap: () {
                                _deleteTokoHandler(penjual['Toko']?['id']);
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.transparent,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/images/round-delete.svg',
                                    width: 24,
                                    height: 24,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  )),
                ]);
              }).toList()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Menampilkan ${start + 1} - $end dari ${filteredList.length}"),
            Row(
              children: [
                IconButton(
                  onPressed: currentPage > 0
                      ? () => setState(() => currentPage--)
                      : null,
                  icon: Icon(Icons.chevron_left),
                ),
                Text('${currentPage + 1} / $totalPages'),
                IconButton(
                  onPressed: currentPage < totalPages - 1
                      ? () => setState(() => currentPage++)
                      : null,
                  icon: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _detailTokoHandler(penjualId, tokoId) async {
    final detail = await UserService().getAllPenjualById(penjualId);

    if (detail['message'] == "Successfully retrieved all penjual data") {
      final toko = detail['data']['Toko'];
      final rekening = detail['data']['Rekening'];

      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 10,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detail Toko',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 8),
                    _buildDetailRow(
                        'Nama Penjual', detail['data']['name'] ?? '-'),
                    _buildDetailRow('Nama Toko', toko?['nama'] ?? '-'),
                    _buildDetailRow(
                        'No Handphone', detail['data']['phone'] ?? '-'),
                    _buildDetailRow('Alamat Toko', toko?['alamat'] ?? '-'),
                    _buildDetailRow(
                        'Deskripsi Toko', toko?['deskripsi'] ?? '-'),
                    _buildDetailRow(
                        'Nama Rekening', rekening?['namaPenerima'] ?? '-'),
                    _buildDetailRow(
                        'Jenis Rekening', rekening?['namaBank'] ?? '-'),
                    _buildDetailRow('Nomor Rekening',
                        rekening?['nomorRekening']?.toString() ?? '-'),
                    SizedBox(height: 24),
                    Align(
                        alignment: Alignment.centerRight,
                        child: widget.onDelete == true
                            ? TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Color.fromARGB(255, 52, 161, 175),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Tutup',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                      onPressed: () async {
                                        try {
                                          final response = await tokoService()
                                              .rejectToko(tokoId);
                                          if (response['message'] ==
                                              "Toko rejected successfully") {
                                            ToastHelper.showSuccessToast(
                                                context,
                                                "Permintaan Toko berhasil ditolak");
                                          } else {
                                            ToastHelper.showErrorToast(context,
                                                "Gagal menolak permintaan Toko: ${response['message']}");
                                          }
                                        } catch (e) {
                                          ToastHelper.showErrorToast(context,
                                              "Gagal menolak permintaan Toko: $e");
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Tolak',
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                  TextButton(
                                      onPressed: () async {
                                        try {
                                          final response = await tokoService()
                                              .activateToko(tokoId);
                                          if (response['message'] ==
                                              "Toko activated successfully") {
                                            ToastHelper.showSuccessToast(
                                                context,
                                                "Permintaan Toko berhasil diterima");
                                          } else {
                                            ToastHelper.showErrorToast(context,
                                                "Gagal menerima permintaan Toko: ${response['message']}");
                                          }
                                        } catch (e) {
                                          ToastHelper.showErrorToast(context,
                                              "Gagal menerima permintaan Toko: $e");
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Terima',
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                ],
                              )),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Detail Toko tidak ditemukan')),
      );
    }
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130, // Menyelaraskan titik dua
            child: Text(
              '$title:',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
