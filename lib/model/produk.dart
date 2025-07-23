class Produk {
  final String id;
  final String nama;
  final String deskripsi;
  final String gambar;
  final int stok;
  final String satuan;
  final int harga;
  final bool isDeleted;
  final String createdAt;
  final String? updatedAt;
  final String tokoId;
  final String? TypeToko;

  Produk(
      {required this.id,
      required this.nama,
      required this.deskripsi,
      required this.gambar,
      required this.stok,
      required this.satuan,
      required this.harga,
      required this.isDeleted,
      required this.createdAt,
      this.updatedAt,
      required this.tokoId,
      this.TypeToko});

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
        id: json['id'],
        nama: json['nama'],
        deskripsi: json['deskripsi'],
        gambar: json['gambar'],
        stok: json['stok'],
        satuan: json['satuan'],
        harga: json['harga'],
        isDeleted: json['isDeleted'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        tokoId: json['TokoId'],
        TypeToko: json['Toko'] != null ? json['Toko']['TypeToko'] : null);
  }
}
