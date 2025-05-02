class TokoData {
  String? id;
  String? nama;
  String? phone;
  String? alamat;
  String? logoToko;
  String? deskripsi;
  bool? isDeleted;
  String? tokoStatus;
  String? createdAt;
  String? updatedAt;
  String? userId;

  TokoData({
    this.id,
    this.nama,
    this.phone,
    this.alamat,
    this.logoToko,
    this.deskripsi,
    this.isDeleted,
    this.tokoStatus,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  TokoData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    phone = json['phone'];
    alamat = json['alamat'];
    logoToko = json['logoToko'];
    deskripsi = json['deskripsi'];
    isDeleted = json['isDeleted'];
    tokoStatus = json['tokoStatus'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['UserId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nama'] = nama;
    data['phone'] = phone;
    data['alamat'] = alamat;
    data['logoToko'] = logoToko;
    data['deskripsi'] = deskripsi;
    data['isDeleted'] = isDeleted;
    data['tokoStatus'] = tokoStatus;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['UserId'] = userId;
    return data;
  }
}