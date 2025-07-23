import 'package:flutter/material.dart';
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
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama toko...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.search,
                  color: const Color(0xFF34A1AF),
                  size: 22,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey[800],
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                currentPage = 0;
              });
            },
          ),
        ),
        filteredList.isEmpty
            ? Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        searchQuery.isEmpty
                            ? 'Belum ada data toko'
                            : 'Tidak ada toko yang ditemukan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (searchQuery.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          'Coba gunakan kata kunci lain',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isSmallScreen =
                          MediaQuery.of(context).size.width < 600;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            headingRowHeight: 60,
                            dataRowMaxHeight: 70,
                            columnSpacing: isSmallScreen ? 16 : 32,
                            horizontalMargin: isSmallScreen ? 12 : 20,
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFF34A1AF).withOpacity(0.1),
                            ),
                            columns: [
                              DataColumn(
                                  label: SizedBox(
                                width: isSmallScreen ? 60 : 80,
                                child: Text(
                                  "Logo",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF34A1AF),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: SizedBox(
                                width: isSmallScreen ? 120 : 180,
                                child: Text(
                                  "Nama Toko",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF34A1AF),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: SizedBox(
                                width: isSmallScreen ? 100 : 120,
                                child: Text(
                                  "Aksi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF34A1AF),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )),
                            ],
                            rows: paginatedList.asMap().entries.map((entry) {
                              final penjual = entry.value;
                              return DataRow(
                                color:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return const Color(0xFF34A1AF)
                                          .withOpacity(0.05);
                                    }
                                    return null;
                                  },
                                ),
                                cells: [
                                  DataCell(
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey[100],
                                        radius: isSmallScreen ? 18 : 22,
                                        child: ClipOval(
                                          child: Image.network(
                                            penjual['Toko']?['logoToko'] ??
                                                'https://res.cloudinary.com/do4mvm3ta/image/upload/v1746673871/clxx1mjmoqocslj9ogjh.jpg',
                                            width: isSmallScreen ? 36 : 44,
                                            height: isSmallScreen ? 36 : 44,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.store,
                                                color: Colors.grey[400],
                                                size: isSmallScreen ? 18 : 22,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      width: isSmallScreen ? 120 : 180,
                                      child: Text(
                                        penjual['Toko']?['nama'] ?? '-',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: isSmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: const Color(0xFF34A1AF)
                                                  .withOpacity(0.1),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                _detailTokoHandler(
                                                    penjual['id'],
                                                    penjual['Toko']?['id']);
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    isSmallScreen ? 8 : 10),
                                                child: Icon(
                                                  Icons.visibility_outlined,
                                                  size: isSmallScreen ? 20 : 22,
                                                  color:
                                                      const Color(0xFF34A1AF),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (widget.onDelete == true) ...[
                                            SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color:
                                                    Colors.red.withOpacity(0.1),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  _deleteTokoHandler(
                                                      penjual['Toko']?['id']);
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      isSmallScreen ? 8 : 10),
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size:
                                                        isSmallScreen ? 20 : 22,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
        if (filteredList.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(
                MediaQuery.of(context).size.width > 600 ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: MediaQuery.of(context).size.width > 400
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Menampilkan ${start + 1} - $end dari ${filteredList.length}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: currentPage > 0
                                  ? const Color(0xFF34A1AF).withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: currentPage > 0
                                  ? () => setState(() => currentPage--)
                                  : null,
                              icon: Icon(
                                Icons.chevron_left,
                                color: currentPage > 0
                                    ? const Color(0xFF34A1AF)
                                    : Colors.grey[400],
                              ),
                              iconSize: 20,
                              constraints: BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34A1AF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${currentPage + 1} / $totalPages',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF34A1AF),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: currentPage < totalPages - 1
                                  ? const Color(0xFF34A1AF).withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: currentPage < totalPages - 1
                                  ? () => setState(() => currentPage++)
                                  : null,
                              icon: Icon(
                                Icons.chevron_right,
                                color: currentPage < totalPages - 1
                                    ? const Color(0xFF34A1AF)
                                    : Colors.grey[400],
                              ),
                              iconSize: 20,
                              constraints: BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        "Menampilkan ${start + 1} - $end dari ${filteredList.length}",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: currentPage > 0
                                  ? const Color(0xFF34A1AF).withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: currentPage > 0
                                  ? () => setState(() => currentPage--)
                                  : null,
                              icon: Icon(
                                Icons.chevron_left,
                                color: currentPage > 0
                                    ? const Color(0xFF34A1AF)
                                    : Colors.grey[400],
                              ),
                              iconSize: 18,
                              constraints: BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34A1AF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${currentPage + 1} / $totalPages',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF34A1AF),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: currentPage < totalPages - 1
                                  ? const Color(0xFF34A1AF).withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: currentPage < totalPages - 1
                                  ? () => setState(() => currentPage++)
                                  : null,
                              icon: Icon(
                                Icons.chevron_right,
                                color: currentPage < totalPages - 1
                                    ? const Color(0xFF34A1AF)
                                    : Colors.grey[400],
                              ),
                              iconSize: 18,
                              constraints: BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 16,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width > 600 ? 24 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34A1AF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.store,
                            color: const Color(0xFF34A1AF),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detail Toko',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                'Informasi lengkap toko',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.grey[300]!,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
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
                    SizedBox(height: 32),
                    Align(
                        alignment: Alignment.centerRight,
                        child: widget.onDelete == true
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF34A1AF),
                                      const Color(0xFF2A8A96),
                                    ],
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.close, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Tutup',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Flexible(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                        child: TextButton(
                                            onPressed: () async {
                                              try {
                                                final response =
                                                    await tokoService()
                                                        .rejectToko(tokoId);
                                                if (response['message'] ==
                                                    "Toko rejected successfully") {
                                                  ToastHelper.showSuccessToast(
                                                      context,
                                                      "Permintaan Toko berhasil ditolak");
                                                } else {
                                                  ToastHelper.showErrorToast(
                                                      context,
                                                      "Gagal menolak permintaan Toko: ${response['message']}");
                                                }
                                              } catch (e) {
                                                ToastHelper.showErrorToast(
                                                    context,
                                                    "Gagal menolak permintaan Toko: $e");
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              600
                                                          ? 20
                                                          : 12,
                                                  vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.close, size: 18),
                                                if (MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    400) ...[
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Tolak',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF34A1AF),
                                              const Color(0xFF2A8A96),
                                            ],
                                          ),
                                        ),
                                        child: TextButton(
                                            onPressed: () async {
                                              try {
                                                final response =
                                                    await tokoService()
                                                        .activateToko(tokoId);
                                                if (response['message'] ==
                                                    "Toko activated successfully") {
                                                  ToastHelper.showSuccessToast(
                                                      context,
                                                      "Permintaan Toko berhasil diterima");
                                                } else {
                                                  ToastHelper.showErrorToast(
                                                      context,
                                                      "Gagal menerima permintaan Toko: ${response['message']}");
                                                }
                                              } catch (e) {
                                                ToastHelper.showErrorToast(
                                                    context,
                                                    "Gagal menerima permintaan Toko: $e");
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              600
                                                          ? 20
                                                          : 12,
                                                  vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check, size: 18),
                                                if (MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    400) ...[
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Terima',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            child: Text(
              '$title:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF34A1AF),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
