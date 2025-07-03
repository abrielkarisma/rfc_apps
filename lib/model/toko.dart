class TokoData {
  final String id;
  final String nama;
  final String phone;
  final String alamat;
  final String logoToko;
  final String deskripsi;
  final bool isDeleted;
  final String tokoStatus;
  final String createdAt;
  final String updatedAt;
  final String TypeToko;
  final String userId;

  TokoData({
    required this.id,
    required this.nama,
    required this.phone,
    required this.alamat,
    required this.logoToko,
    required this.deskripsi,
    required this.isDeleted,
    required this.tokoStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.TypeToko,
    required this.userId,
  });

  factory TokoData.fromJson(Map<String, dynamic> json) {
    return TokoData(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      phone: json['phone'] ?? '',
      alamat: json['alamat'] ?? '',
      logoToko: json['logoToko'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      tokoStatus: json['tokoStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      TypeToko: json['TypeToko'] ?? '',
      userId: json['UserId'] ?? '',
    );
  }
}
