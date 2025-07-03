class JenisBudidaya {
  final String id;
  final String nama;
  final String latin;
  final bool status;
  final String detail;
  final String tipe;
  final String gambar;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  JenisBudidaya({
    required this.id,
    required this.nama,
    required this.latin,
    required this.status,
    required this.detail,
    required this.tipe,
    required this.gambar,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JenisBudidaya.fromJson(Map<String, dynamic> json) {
    return JenisBudidaya(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      latin: json['latin'] ?? '',
      status: json['status'] ?? false,
      detail: json['detail'] ?? '',
      tipe: json['tipe'] ?? '',
      gambar: json['gambar'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Satuan {
  final String id;
  final String nama;
  final String lambang;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  Satuan({
    required this.id,
    required this.nama,
    required this.lambang,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Satuan.fromJson(Map<String, dynamic> json) {
    return Satuan(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      lambang: json['lambang'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class KomoditasData {
  final String id;
  final String nama;
  final String gambar;
  final int jumlah;
  final bool hapusObjek;
  final String tipeKomoditas;
  final bool isDeleted;
  final String? produkId;
  final String createdAt;
  final String updatedAt;
  final String jenisBudidayaId;
  final String satuanId;
  final JenisBudidaya jenisBudidaya;
  final Satuan satuan;

  KomoditasData({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.jumlah,
    required this.hapusObjek,
    required this.tipeKomoditas,
    required this.isDeleted,
    required this.produkId,
    required this.createdAt,
    required this.updatedAt,
    required this.jenisBudidayaId,
    required this.satuanId,
    required this.jenisBudidaya,
    required this.satuan,
  });

  factory KomoditasData.fromJson(Map<String, dynamic> json) {
    return KomoditasData(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      gambar: json['gambar'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      hapusObjek: json['hapusObjek'] ?? false,
      tipeKomoditas: json['tipeKomoditas'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      produkId: json['produkId'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      jenisBudidayaId: json['JenisBudidayaId'] ?? '',
      satuanId: json['SatuanId'] ?? '',
      jenisBudidaya: JenisBudidaya.fromJson(json['JenisBudidaya'] ?? {}),
      satuan: Satuan.fromJson(json['Satuan'] ?? {}),
    );
  }
}
